# ADO Provider

Routes `/work` commands to Azure DevOps Boards via the `az boards` CLI. Every external write also creates or updates a local mirror (dual-write pattern per `provider.md`).

## Prerequisites

Required tools and authentication:

| Requirement | Check Command | Install |
|-------------|--------------|---------|
| Azure CLI | `az --version` | [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| DevOps extension | `az extension show --name azure-devops` | `az extension add --name azure-devops` |
| Authentication | `az account show` | `az login` (interactive browser auth) |
| Defaults configured | `az devops configure --list` | `az devops configure --defaults organization=<org> project=<project>` |

### Prerequisite Check

Run this sequence to verify readiness:

```bash
az --version 2>/dev/null && echo "az CLI: OK" || echo "az CLI: MISSING"
az extension show --name azure-devops --query name -o tsv 2>/dev/null && echo "DevOps ext: OK" || echo "DevOps ext: MISSING"
az account show --query user.name -o tsv 2>/dev/null && echo "Auth: OK" || echo "Auth: EXPIRED"
```

If any check fails, report as a **blocking** error with install/fix instructions.

## Reading Configuration

Extract provider config from the `## Work Provider` section in CONTEXT.md:

| Field | Variable | Example |
|-------|----------|---------|
| `**Organization**:` | `ORG` | `https://dev.azure.com/southbendin` |
| `**Project**:` | `PROJECT` | `Digital - Product Portfolio` |
| `**Process Template**:` | `TEMPLATE` | `Digital Product Portfolio - Electric Boogaloo` |

### Type-State Mappings

Read the `### Type → State Mappings` subsection in CONTEXT.md. Each type has a mapping table:

```
| Our Stage | ADO State |
|-----------|-----------|
| Captured  | To Do     |
| ...       | ...       |
```

Parse these tables into a lookup: `(type, our_stage) → ado_state` and `(type, ado_state) → our_stage`.

If a type→state mapping is missing for a particular stage, the transition is **not valid** for that type. Report it as a blocking error with the valid transitions listed.

## Operations

### add

Create a work item in ADO and a local mirror.

1. **Parse description** and detect category (same as current `work.md` step 1-4)
2. **Detect ADO type** using keyword matching:

   | Keywords | ADO Type |
   |----------|----------|
   | Default (no match) | Task |
   | "bug", "defect", "broken" | Bug |
   | "issue", "problem", "outage" | Issue |
   | "request", "intake", "department" | Request |
   | "investigate", "explore", "feasibility" | Discovery |
   | "blocker", "blocked", "constraint" | Constraint |
   | "maintenance", "recurring", "operational" | Maintenance |
   | "scope change", "change order", "added scope" | Change Order |

3. **Confirm type** via AskUserQuestion:

   ```javascript
   {
     question: "Create this as a '{detected_type}' in ADO?",
     header: "ADO Type",
     options: [
       { label: "Yes — {detected_type}", description: "Create as {detected_type} in ADO" },
       { label: "Change type", description: "Pick a different work item type" }
     ],
     multiSelect: false
   }
   ```

   If "Change type", ask conversationally (too many ADO types for a menu).

4. **Look up initial state** — Read the type→state mapping from CONTEXT.md. Use the ADO state mapped to `Captured` as the initial state.

5. **Create in ADO**:

   ```bash
   az boards work-item create \
     --type "{type}" \
     --title "{title}" \
     --org "{ORG}" \
     --project "{PROJECT}" \
     --output json
   ```

   Parse the response JSON for `id` and `url`.

6. **Create local mirror** — Standard item file in `.claude/work/items/W-NNN.md` with:
   - All standard fields (status: captured, category, project, etc.)
   - `## Provider Integration` section with: Provider: ado, External ID: {ado_id}, URL: {ado_url}, Type: {type}, Sync: current, Last Synced: {now}

7. **Regenerate board** (see Board Generation in `work.md`)

8. **Confirm**: "Added W-NNN: '{title}' to {category} (captured) — ADO {type} #{ado_id}"

**On CLI failure**: Fall back to Offline Fallback Protocol — create local item with `**Sync**: pending`, warn user.

### list

Query ADO and merge with the local board.

1. **Build WIQL query**:

   ```bash
   az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.WorkItemType] FROM workitems WHERE [System.TeamProject] = '{PROJECT}' AND [System.State] <> 'Archived' ORDER BY [System.ChangedDate] DESC" --org "{ORG}" --output json
   ```

2. **Map ADO states to our stages** — For each result, look up `(type, ado_state) → our_stage` using the CONTEXT.md mappings. Items with unmapped states are shown with their raw ADO state.

3. **Merge with local item data** — Local items are authoritative for display. ADO results can surface items not yet tracked locally (created outside Claude) or update stale local states.

4. **Check for pending sync** — Scan item files for `**Sync**: pending`. If found, append reminder: "N items pending sync to ADO. Run `/work sync` to push."

5. **Display merged board**

### view

Show merged local + ADO details for an item.

1. **Read local item file** from `.claude/work/items/<id>.md`
2. **Extract ADO ID** from `## Provider Integration` section
3. **Fetch from ADO** (if Provider Integration section exists):

   ```bash
   az boards work-item show --id {ado_id} --org "{ORG}" --output json
   ```

4. **Merge and display** — Show local content with ADO state, comments, and links overlaid

### move

Transition state in ADO and locally.

1. **Read item file** — Extract ADO ID and Type from Provider Integration section
2. **Look up target ADO state** — Use `(type, target_stage) → ado_state` from CONTEXT.md mappings
3. **Validate transition** — If no mapping exists for this type + target stage combination, report as blocking error:
   "Cannot move {type} to {target_stage}. Valid stages for {type}: {list of mapped stages}"
4. **Update in ADO**:

   ```bash
   az boards work-item update \
     --id {ado_id} \
     --state "{ado_state}" \
     --org "{ORG}" \
     --output json
   ```

5. **Update locally** — Standard item file status update, then regenerate board
6. **Update sync metadata** — Set `**Sync**: current`, update `**Last Synced**:`

**On invalid ADO state transition**: ADO may reject transitions that skip intermediate states. If the API returns an error, report the error and show the valid transitions for the current state.

### start

Delegate to **move** with target stage `in-progress`. Additionally:

1. Resolve provider and execute move to In Progress
2. Prompt for assignment (if Team Members configured)
3. Suggest branch name (same as current `work.md`)
4. Record branch in item file

### review

Delegate to **move** with target stage `in-review`. Additionally:

1. Resolve provider and execute move to In Review
2. Record PR link if provided

### done

Delegate to **move** with target stage `done`. Additionally:

1. Resolve provider and execute move to Done
2. **Resolve predecessor links** — Query ADO for items linked to this one:

   ```bash
   az boards work-item show --id {ado_id} --org "{ORG}" --expand relations --output json
   ```

   Parse the `relations` array for `System.LinkTypes.Dependency-Reverse` links. For each linked item, check if the completion of this item unblocks it.

3. **Archive locally** — Move item file to `.claude/work/archive/`
4. **Check for locally unblocked items** — Same as current `work.md` step 5

### block

Create a dependency link in ADO and update locally.

1. **Read item file** — Get ADO ID for the item being blocked
2. **Resolve blocker** — If blocker is a `W-NNN` ID, read its item file to get the ADO ID. If blocker is free text, skip ADO link creation (local-only block).
3. **Create ADO link** (if both items have ADO IDs):

   ```bash
   az boards work-item relation add \
     --id {blocked_ado_id} \
     --relation-type "System.LinkTypes.Dependency-Reverse" \
     --target-id {blocker_ado_id} \
     --org "{ORG}" \
     --output json
   ```

   `Dependency-Reverse` means "this item is blocked by the target" (Predecessor link in ADO UI).

4. **Update locally** — Standard `**Blocked By**:` field update, then regenerate board

### unblock

Remove a dependency link in ADO and update locally.

1. **Read item file** — Get ADO ID for the blocked item
2. **Resolve blocker** — Get the blocker's ADO ID (if it's a `W-NNN` with Provider Integration)
3. **Remove ADO link** (if both items have ADO IDs):

   ```bash
   az boards work-item relation remove \
     --id {blocked_ado_id} \
     --relation-type "System.LinkTypes.Dependency-Reverse" \
     --target-id {blocker_ado_id} \
     --org "{ORG}" \
     --yes \
     --output json
   ```

4. **Update locally** — Remove blocker from `**Blocked By**:` field, then regenerate board

### sync

Push pending local items and pull external changes.

1. **Scan for pending items** — Read all item files in `.claude/work/items/`, find those with `**Sync**: pending`
2. **For each pending item**:
   - If no External ID: Create in ADO (same as `add` step 5), update Provider Integration with new ID
   - If has External ID: Update in ADO with current local state
   - On success: Set `**Sync**: current`, update `**Last Synced**:`
   - On failure: Keep as pending, report the error
3. **Report summary**: "Synced N items. M still pending. K failed."

### import

Import an ADO work item as a local item.

1. **Fetch from ADO**:

   ```bash
   az boards work-item show --id {ado_id} --org "{ORG}" --output json
   ```

2. **Check if already imported** — Scan item files for matching External ID in Provider Integration section
3. **Map ADO state to our stage** — Use `(type, ado_state) → our_stage`
4. **Detect category** from ADO fields or keywords
5. **Confirm category** with AskUserQuestion
6. **Create local item file** with Provider Integration section
7. **Regenerate board** (see Board Generation in `work.md`)
8. **Confirm**: "Imported ADO #{ado_id} as W-NNN: '{title}'"

### export

Push a local-only item to ADO.

1. **Read item file** — Verify no Provider Integration section exists (not already linked)
2. **Detect ADO type** — Use keyword matching (same as `add` step 2)
3. **Confirm type** with AskUserQuestion
4. **Create in ADO** — Same as `add` step 5
5. **Update item file** — Add Provider Integration section with new ADO ID
6. **Update sync metadata** — `**Sync**: current`
7. **Confirm**: "Exported W-NNN as ADO {type} #{ado_id}: {url}"

### Local-Only Operations

The following operations do not route to ADO. They execute locally using the same behavior as the local provider (see `local.md`):

- **skip** — Local-only terminal state management
- **revive** — Local-only reactivation from Skipped
- **refine** — Local-only shaping discussion (invokes ideate skill)
- **ready** — Local-only readiness gate

## Windows CLI Notes

The `az` CLI on Windows (especially under MSYS/Git Bash) has common gotchas:

| Issue | Workaround |
|-------|------------|
| `az` not found in PATH | Try full path: `"/c/Program Files/Microsoft SDKs/Azure/CLI2/wbin/az.cmd"` or ensure `az` is in PATH |
| Unicode output garbled | Set `PYTHONIOENCODING=utf-8` before az commands |
| Project names with spaces | URL-encode spaces in `--project` values: `"Digital%20-%20Product%20Portfolio"` or use `--detect true` if defaults are configured |
| JSON output required | Always use `--output json` for machine-parseable results |
| Long commands | Use `--detect true` to inherit defaults from `az devops configure` instead of passing `--org` and `--project` on every call |

### Recommended pattern

```bash
PYTHONIOENCODING=utf-8 az boards work-item create \
  --type "Task" \
  --title "My task" \
  --detect true \
  --output json
```

Using `--detect true` reads org and project from `az devops configure` defaults, avoiding repeated long arguments and space-encoding issues.

## Error Handling

| Error | Severity | Action |
|-------|----------|--------|
| `az` CLI not found | **Blocking** | Stop. Report install instructions. Cannot proceed without CLI. |
| `azure-devops` extension missing | **Blocking** | Stop. Report: `az extension add --name azure-devops` |
| Auth expired (`AADSTS` error) | **Blocking** | Stop. Report: "Azure auth expired. Run `az login` to re-authenticate." |
| Network timeout | **Transient** | Retry once. If still failing, fall back to Offline Fallback Protocol. |
| Rate limited (429) | **Transient** | Wait briefly, retry once. If still failing, fall back to Offline Fallback Protocol. |
| Invalid state transition | **Blocking** | Report the error with valid transitions for the current type and state. Ask user for direction. |
| Project not found | **Blocking** | Report: "ADO project '{PROJECT}' not found. Check the **Project** field in CONTEXT.md `## Work Provider`." |
| Work item not found | **Blocking** | Report: "ADO work item #{id} not found. It may have been deleted or moved." |
| Permission denied | **Blocking** | Report: "Insufficient permissions for this ADO operation. Check your access level in the ADO project." |

## Doc Operations

Routes `/doc` commands to ADO Wiki. Requires a `## Doc Provider` section in CONTEXT.md with `**Provider**: ado` and `**Target**: <wiki-name>`.

### Prerequisites

Same Azure CLI requirements as work operations. Additionally:

```bash
az devops wiki list --org "{ORG}" --project "{PROJECT}" --output json
```

If this fails, report: "Cannot access ADO Wiki. Verify wiki exists and you have permissions."

### Reading Doc Configuration

Extract doc config from the `## Doc Provider` section in CONTEXT.md:

| Field | Variable | Example |
|-------|----------|---------|
| `**Target**:` | `WIKI` | `MyProject.wiki` |
| `**Auto-route**:` | `AUTO_ROUTE` | `true` |

### doc_publish

Push a local document to ADO Wiki.

1. **Read the local file** at `<path>`
2. **Determine wiki path** — Map local path to wiki page path:
   - `docs/api/endpoints.md` → `/api/endpoints`
   - `docs/guides/getting-started.md` → `/guides/getting-started`
3. **Check if page exists**:

   ```bash
   az devops wiki page show \
     --wiki "{WIKI}" \
     --path "{wiki_path}" \
     --org "{ORG}" \
     --project "{PROJECT}" \
     --output json 2>/dev/null
   ```

4. **Create or update**:

   ```bash
   # Create new page
   az devops wiki page create \
     --wiki "{WIKI}" \
     --path "{wiki_path}" \
     --file-path "{local_path}" \
     --org "{ORG}" \
     --project "{PROJECT}" \
     --output json

   # Update existing page (include eTag from show)
   az devops wiki page update \
     --wiki "{WIKI}" \
     --path "{wiki_path}" \
     --file-path "{local_path}" \
     --version "{etag}" \
     --org "{ORG}" \
     --project "{PROJECT}" \
     --output json
   ```

5. **Report**: "Published `<path>` to ADO Wiki at `{wiki_path}`"

### doc_list

List wiki pages from ADO.

1. **Query wiki pages**:

   ```bash
   az devops wiki page show \
     --wiki "{WIKI}" \
     --path "/" \
     --include-content false \
     --recurse \
     --org "{ORG}" \
     --project "{PROJECT}" \
     --output json
   ```

2. **Parse response** — Extract page paths and metadata
3. **Display as table**:

   ```
   ADO Wiki: {WIKI}

   | Wiki Path | Last Modified |
   |-----------|--------------|
   | /api/endpoints | 2026-03-01 |
   | /guides/getting-started | 2026-02-15 |

   N pages found
   ```

### doc_sync

Bidirectional sync between local `docs/` and ADO Wiki.

1. **List local docs** — Scan `docs/` directory
2. **List wiki pages** — Execute `doc_list`
3. **Compare** — Map local paths to wiki paths, identify differences
4. **Present sync plan** to user (same pattern as `/doc sync` in `doc.md`)
5. **Execute** — Publish or import based on user choice

### doc_import

Pull a wiki page to local.

1. **Fetch page content**:

   ```bash
   az devops wiki page show \
     --wiki "{WIKI}" \
     --path "{wiki_path}" \
     --include-content true \
     --org "{ORG}" \
     --project "{PROJECT}" \
     --output json
   ```

2. **Parse content** from the JSON response
3. **Write locally** — Save to `docs/` with path matching the wiki structure
4. **Report**: "Imported `{wiki_path}` to `<local_path>`"

### doc_review

Check ADO Wiki pages for staleness compared to local docs.

1. **Fetch wiki page** for the target path
2. **Compare content** with local version (if exists)
3. **Flag differences** — content drift, missing pages, stale references

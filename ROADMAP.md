# South Bend Digital Services — Q2 2026 Interactive Report · Roadmap

Parking lot for future enhancements to `south_bend_interactive_report.html`.

---

## ✅ Shipped

- XP desktop framing with Bliss wallpaper
- Draggable windows, taskbar, Start menu, clock
- Welcome / Services Overview / City Stats / What Changed / ReadMe windows
- Clippy with rotating tips (Next / Dismiss)
- Paint (canvas with 24-color palette)
- Minesweeper (playable 9×9, 10 mines, timer, face states)
- SBWinamp (8-track city-themed playlist, animated EQ bars, scrolling marquee)
- SBShare (Napster/LimeWire-style P2P UI with fake city files, live progress, search)
- Idle screensaver (bouncing "CITY OF SOUTH BEND" text)

---

## 🎯 Next session (priority build)

### 1. AIM-style chat with team voices

Three buddies, each with their own voice: **Kerry**, **Jeff**, **Lucy**.

**Shape:**
- Buddy list window (pinnable, upper-right corner)
- Status dots: 🟢 online / 🟡 idle / 🔴 away (rotates)
- Click a buddy → chat window opens with their personality
- Branching script (3-option responses) at each step
- Away-message rotation
- Iconic AIM visual: blue titlebar, yellow smiley, big buddy name at top

**Voice intake template — send to Kerry, Jeff, and self:**

```
NAME:
AIM HANDLE: e.g. kerry_sb, jeffd_digital, digital_lucy
BUDDY ICON: emoji or simple image they want
STATUS PREFERENCE: online / idle / away (rotates)

1. How do they greet someone? (typical "hey!" style)
2. Three typical away messages (the more in-character, the better)
3. One thing they'd want the reader to know about the team's work
4. Their favorite thing they built/led this year
5. A running joke or signature phrase they use in chat
6. What they'd say if someone asked "what does digital services actually do?"
7. Typing quirks: emojis, caps, punctuation, "lol" vs "haha"
8. Two random questions they might ask the reader
```

**Implementation estimate:** ~30 minutes once voice intakes are filled out.

### 2. Yellow sticky note with live to-do list

- Pinned to a corner of the desktop, slightly rotated
- Handwritten-style font (e.g. "Kalam" or "Caveat" from Google Fonts)
- Draggable
- Styled like Stickies by Zhorn Software (the third-party XP-era standard — built-in Sticky Notes didn't ship until Win 7)
- **Content:** actual team to-dos. Examples:
  - Finish ADA audit (5 domains remaining)
  - Wire up 311 dashboard
  - Budget tool Phase 2
  - Permits → Step 3 UX pass
  - Ship winter salt map refresh

### 3. Visual Studio .NET window

The meta-moment — shows the "real" work behind the XP joke.

- Solution Explorer (tree) with city projects:
  - `SouthBend.Permits`
  - `SouthBend.ETL`
  - `SouthBend.Accessibility`
  - `SouthBend.Web`
  - `SouthBend.GIS`
- Code pane with a real-looking C# or TypeScript snippet
- Build Output window that "builds" with funny-but-real log lines:
  ```
  > Deploying permit_api...                     [OK]
  > Running 50+ ETL pipelines...                [OK]
  > Compiling accessibility fixes (20 domains)…  [OK]
  ========= Build succeeded. 0 warnings. Ship it. =========
  ```

### 4. Command Prompt (`cmd.exe`)

Black window with working canned commands:

| Command | Output |
|---|---|
| `whoami` | `DIGITAL_SERVICES\lucy` |
| `ipconfig` | Fake city network w/ comedy hostnames |
| `dir` | Lists files matching desktop |
| `uptime` | "Up 24/7 since forever" |
| `services` | Running city services list |
| `ping southbendindiana.gov` | 4 replies, low latency |
| `sudo <anything>` | "This isn't a Linux machine, friend." |
| `help` | Hints at other commands |

---

## 🧊 Backlog (V3+ if there's appetite)

- **Task Manager** — processes list with city services as `.exe` files, animated CPU/memory bars, `paper_forms.exe` showing "Not Responding"
- **Internet Explorer 6** — early-2000s mockup of southbendindiana.gov. Visitor counter, "Best viewed at 800×600," auto-playing MIDI warning. Before/after on accessibility becomes visual.
- **Recycle Bin** — desktop icon; opening shows "deleted" things: `paper_permit_forms.pdf`, `fax_cover_sheet.doc`, `in_person_visit_only.txt`
- **BSOD easter egg** — triggered by a secret (Konami code?), fake blue screen for 3 sec, recovers: "just kidding — we have redundancy now."
- **Disk Defragmenter** — iconic colored-block viz, 60-sec "optimizing City of South Bend services"
- **Rover the Search Dog** — appears when you "search files"
- **Yellow system tray balloon** — "Your computer might be at risk" with a city-services punchline
- **Project ticker** — scrolling band of city wins; likely redundant with City Stats window, skip unless repurposed
- **3D Pinball: Space Cadet** — beloved but heavy lift; skip unless fully committed

---

## 🔌 Live data connections (when we're ready)

When you want the report to pull real numbers instead of hardcoded ones:

### Priority integrations
1. **311 tickets** — powers `311_bot` in AIM + Task Manager process + SBShare files
2. **Permit submissions** — powers the "Form submissions / quarter" counter
3. **Website analytics** — powers "Monthly website visitors"
4. **Accessibility audit status** — powers the ADA compliance percentage
5. **ETL pipeline count** — could auto-increment the stat in real time

### Approach options
- **Static JSON refresh** — regenerated nightly from data sources, committed to repo. Simplest, zero backend.
- **Client-side fetch** — report calls a public API endpoint. Needs CORS + a small backend.
- **Build-time generation** — GitHub Action rebuilds report on data change.

**Recommended first step:** static JSON refresh for the City Stats numbers. Smallest change, biggest "live report" feeling.

---

## 📚 Reference

- Original Figma file: (add URL)
- WCAG 2.1 AA audit: see `ACCESSIBILITY_AUDIT.md`
- Stickies by Zhorn Software: https://www.zhornsoftware.co.uk/stickies/ (inspiration for sticky note)

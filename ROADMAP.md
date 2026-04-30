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

## ♿ Accessibility compliance (WCAG 2.1 AA) — Option A: Responsive switchover

Goal: bring the existing interactive report to WCAG 2.1 AA without abandoning the XP visual theme. The ironic gap between the report's message (95% ADA compliance) and its current state (fails AA) gets closed.

Full findings are in `ACCESSIBILITY_AUDIT.md`. This section is the **build plan**.

**Status: Phases 1–5 ✅ complete. Phase 6 (verification with axe + screen reader) still pending.**

**Estimated effort:** 4–8 hours focused work + screen-reader testing.

### Phase 1 — Zero visual impact (quick wins, ~1–2 hr)

Do these first. No one will notice they shipped; lots of compliance points covered.

- [ ] Replace `ondblclick` with single-click-plus-Enter across all desktop icons and Start menu items
- [ ] Convert every `<div onclick>` to `<button>` or `[role="button"][tabindex="0"]` with `aria-label`
- [ ] Add `role="dialog"`, `aria-labelledby`, `aria-modal="true"` to every `.win`
- [ ] Add `aria-label` to every emoji-only button (✕ → "Close", 🙂 → "New game", ▶ → "Play", ⏭ → "Next track", etc.)
- [ ] Add `<label>` or `aria-label` to `#share-search`
- [ ] Fix color contrast failures:
  - `#AAAAAA` dim stats text → `#767676` (4.54:1 ✅)
  - `.ppt-felt` `#888` → `#767676`
  - `.sm-header-sub` `rgba(255,255,255,.6)` → `rgba(255,255,255,.85)`
- [ ] Remove `user-select: none` from `<body>`
- [ ] Add `aria-live="polite"` to dynamic counters (City Stats numbers, Minesweeper timer/counter, Winamp track time, SBShare progress)
- [ ] Keyboard alternative for Minesweeper right-click flag: pressing `F` or `Space` on focused cell
- [ ] Add `alt=""` (explicit empty) to decorative Figma asset `<img>` tags

### Phase 2 — Tasteful visual additions (~1–2 hr)

Era-authentic additions that *improve* the XP feel.

- [ ] `:focus-visible` styles using classic Windows dotted-outline — looks more XP-authentic than today
- [ ] Keyboard window drag: Alt+Space opens window system menu, arrow keys to move (how real Windows XP works)
- [ ] Skip link at top of page, visually hidden, appears on focus: "Skip to desktop"
- [ ] Proper focus management when opening/closing windows (focus moves to the window; closing returns focus to the icon)
- [ ] ESC key to close the top window, dismiss Clippy, close Start menu

### Phase 3 — Motion & reduced-motion support (~30 min)

- [ ] Wrap all animations in `@media (prefers-reduced-motion: no-preference)` blocks:
  - Clippy wiggle animation
  - Winamp EQ bouncing bars
  - Winamp track marquee scroll
  - SBShare progress bar transitions
  - Stats counter animations
  - Progress bar in PPT slide 3
- [ ] Disable (or make opt-in) the bouncing screensaver when `prefers-reduced-motion: reduce` is set
- [ ] Clippy: do not auto-appear with reduced motion — add a taskbar button to summon

### Phase 4 — Responsive switchover for reflow (~1–2 hr) ⭐ the hard part

Below ~700 px viewport width, switch to **"focused window" mode**:

- [ ] Desktop icons become a vertical scrollable list
- [ ] Taskbar stays at bottom, tapping/keyboard-activating an icon fills the viewport with that one window
- [ ] Only one window shown at a time; switch via taskbar buttons (like mobile OS task switching)
- [ ] Windows no longer drag; they're full-width tile views
- [ ] Close button returns to icon list
- [ ] Start menu slides in from bottom
- [ ] Screensaver disabled in this mode (no value on mobile)
- [ ] Clippy repositions to avoid overlapping full-width content

Branding survives: XP titlebar, Bliss background peeking at edges, taskbar, fonts, colors. Interaction is different but the aesthetic is continuous.

### Phase 5 — Semantic structure (~30 min)

- [ ] Add an `<h1>` for the page (visually hidden if needed) — e.g. "City of South Bend — Digital Services — Q2 2026 Report"
- [ ] Windows get `<h2>` for titles (currently `<span>`)
- [ ] Wrap stats table in proper semantic structure with `<caption>`, `<th scope="col">`
- [ ] Add landmark regions: `<header>` for taskbar area (or `<nav>`), `<main>` for desktop
- [ ] Screen-reader-only description at top: `<p class="sr-only">This is a stylized XP-desktop interactive report. All content is keyboard accessible. Tab through desktop icons, press Enter to open a window.</p>`

### Phase 6 — Verification (~30 min – 1 hr)

- [ ] Run axe-core (browser extension or automated)
- [ ] Run Lighthouse accessibility audit (aim for 95+)
- [ ] Manual keyboard-only walkthrough (no mouse, open every window, play minesweeper, cycle Clippy)
- [ ] Screen reader pass with NVDA or VoiceOver
- [ ] Test at 200% zoom, 400% zoom
- [ ] Test at 320 CSS pixels (iPhone SE / Galaxy Fold outer screen)
- [ ] Test with Windows High Contrast Mode
- [ ] Test with `prefers-reduced-motion: reduce`

### Definition of done

- axe reports zero WCAG 2.1 AA violations
- Lighthouse accessibility score ≥ 95
- All content reachable and operable by keyboard only
- All content announced sensibly by screen reader
- No content clipped at 400% zoom or 320 px width
- Motion-sensitive users have a calm experience

### What survives unchanged

- XP visual theme, fonts, colors, Bliss wallpaper
- Draggable windows (on desktop widths)
- All apps: Paint, Minesweeper, Winamp, SBShare
- Clippy (with reduced-motion respect)
- Start menu, taskbar, clock
- All playful "lean-in" content (SBShare filenames, Winamp playlist, etc.)

### What changes

- Double-click opens → single-click / Enter opens
- Pointer-only → keyboard + pointer
- Screensaver becomes opt-in or reduced-motion-aware
- Mobile gets a simpler stacked view
- Everything is announced by screen readers

---

## 📚 Reference

- Original Figma file: (add URL)
- WCAG 2.1 AA audit: see `ACCESSIBILITY_AUDIT.md`
- Stickies by Zhorn Software: https://www.zhornsoftware.co.uk/stickies/ (inspiration for sticky note)

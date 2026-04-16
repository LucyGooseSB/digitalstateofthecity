# WCAG 2.1 AA Accessibility Audit — Interactive Report

**File audited:** `south_bend_interactive_report.html`
**Standard:** WCAG 2.1 Level AA
**Auditor:** Automated heuristic review (not a substitute for assistive-tech and user testing)
**Date:** 2026-04-16

---

## Executive summary

**Current compliance status: ❌ Does not meet WCAG 2.1 AA.**

The report is a stylized simulation of a Windows XP desktop. That framing is charming and the joke lands, but it is **fundamentally in tension with accessibility norms**: icons require double-click, windows are positioned absolutely with draggable pointer gestures, content is inside canvases and custom-drawn grids, and the whole document uses divs instead of semantic HTML.

This is notable because the report itself highlights South Bend's jump from 50% → 95% ADA Title II compliance on `southbendindiana.gov`. The report *about* accessibility work currently wouldn't pass the audit described in its own What Changed slide.

**Two paths forward — pick one:**

1. **"Accessible View" toggle (recommended)** — Add a prominent link at the top of the page: *"View this report as a standard accessible document →"*. Link to a second file (`south_bend_accessible_report.html`) containing the same data in a plain, semantic, keyboard-friendly document with proper headings, landmarks, and no custom widgets. Keep the XP version for the joke; serve the accessible version to everyone who needs it. This is the pragmatic, industry-standard approach for highly stylized experiences.
2. **Retrofit the XP version to AA** — Possible but extensive work: full keyboard nav, ARIA roles for every window/control, focus management, reduced-motion support, color-contrast fixes, reflow/zoom support. Est. 8–16 hours of focused work and some charm loss.

**Strong recommendation: do option 1.** It's faster, more reliable, and a better experience for disabled users than a heavily retrofitted interactive clone.

---

## Findings by WCAG principle

Severity: 🔴 Blocker · 🟠 Serious · 🟡 Moderate · 🟢 Minor

### 1. Perceivable

| # | Criterion | Status | Severity | Finding |
|---|---|---|---|---|
| 1.1.1 | Non-text Content | ⚠️ Partial | 🟡 | `bliss.png` background has no meaningful `alt` because it's CSS — OK as decoration. Start-button Figma asset `<img>` tags have no `alt` attribute at all (should be `alt=""` if decorative). |
| 1.3.1 | Info and Relationships | ❌ Fail | 🔴 | No semantic structure: no `<h1>`–`<h6>`, no landmarks (`<main>`, `<nav>`, `<header>`), no `<ul>`/`<ol>` for lists. Data is in `<table>` (good) but without `<caption>` or `scope`. |
| 1.3.2 | Meaningful Sequence | ⚠️ Partial | 🟠 | DOM order of windows doesn't reflect reading order; windows are z-index layered and positioned absolutely. |
| 1.4.1 | Use of Color | ✅ Pass | — | Color isn't the sole means of conveying meaning. |
| 1.4.3 | Contrast (Minimum) | ❌ Fail | 🟠 | Specific failures below. |
| 1.4.4 | Resize Text | ❌ Fail | 🟠 | `body { overflow:hidden; height:100vh }` prevents zoom scrolling. Content is clipped above ~150% zoom. |
| 1.4.5 | Images of Text | ✅ Pass | — | No images-of-text found. |
| 1.4.10 | Reflow | ❌ Fail | 🟠 | Fixed absolute pixel positioning. Does not reflow at 320 CSS pixels wide. |
| 1.4.11 | Non-text Contrast | ⚠️ Partial | 🟡 | Window borders (#0a3080 on XP-blue titlebar) pass; some UI elements like the clock and tray icons depend on a darker tray bg — recheck. |
| 1.4.12 | Text Spacing | ⚠️ Partial | 🟡 | Many small text elements use pixel-level `font-size` and tight `line-height`; won't tolerate user overrides. |
| 1.4.13 | Content on Hover/Focus | N/A | — | No hover-revealed tooltips containing essential content. |

**Specific contrast failures:**

| Element | FG | BG | Ratio | AA req | Result |
|---|---|---|---|---|---|
| `.xls-table td.dim` (stats placeholder) | `#AAAAAA` | `#FFFFFF` | 2.85:1 | 4.5:1 | ❌ |
| `.xls-table td.dim` on striped row | `#AAAAAA` | `#F0F0F8` | 2.70:1 | 4.5:1 | ❌ |
| Icon labels over Bliss wallpaper | `#FFFFFF` | variable (sky/grass/cloud) | varies | 4.5:1 | ⚠️ Unreliable — text-shadow masks some spots |
| `.sm-header-sub` in Start menu | `rgba(255,255,255,.6)` on `#3070E0` | ~3.2:1 | 4.5:1 | ❌ |
| `.ppt-felt` attribution text | `#888` | `#FFFFFF` | 3.54:1 | 4.5:1 | ❌ |
| `.row-num` minesweeper side numbers | `#333` | `#D4D0C8` | 7.5:1 | 4.5:1 | ✅ |
| `.winamp-track` | `#F5C82C` | `#000` | 12.6:1 | 4.5:1 | ✅ |

### 2. Operable

| # | Criterion | Status | Severity | Finding |
|---|---|---|---|---|
| 2.1.1 | Keyboard | ❌ Fail | 🔴 | **Most severe issue.** Desktop icons use `ondblclick` only — no keyboard handler, not focusable, no `tabindex`. Windows can be opened only by pointer. Window drag uses `mousedown` only. Paint and Minesweeper are entirely pointer-driven. Start button works with keyboard (it's a `<button>`) but start-menu items are `<div>`s. Clippy buttons are `<button>`s (good) but keyboard users must tab through every window's children first. |
| 2.1.2 | No Keyboard Trap | ⚠️ Unknown | 🟡 | Haven't verified with keyboard-only nav, but nothing obvious traps focus. |
| 2.1.4 | Character Key Shortcuts | ✅ Pass | — | None defined. |
| 2.4.1 | Bypass Blocks | ❌ Fail | 🟠 | No skip link. |
| 2.4.2 | Page Titled | ✅ Pass | — | `<title>City of South Bend - Digital Services - Q2 2026</title>` — descriptive. |
| 2.4.3 | Focus Order | ❌ Fail | 🟠 | No defined tab order; visual order (left column, then right column, then taskbar) doesn't match DOM order. |
| 2.4.4 | Link Purpose | ⚠️ Partial | 🟡 | Start-menu items like "southbendindiana.gov" aren't real links — they look like nav but do nothing. |
| 2.4.6 | Headings and Labels | ❌ Fail | 🟠 | Zero semantic headings. Dialog/window titles are styled `<span>`s. |
| 2.4.7 | Focus Visible | ❌ Fail | 🔴 | No `:focus-visible` styles defined for any interactive element. Default browser outlines are not suppressed but also not enhanced. |
| 2.5.1 | Pointer Gestures | ⚠️ Partial | 🟡 | Window dragging uses single-point drag (allowed by 2.5.1), but no keyboard alternative for positioning. Minesweeper flag uses right-click (`contextmenu`) — needs a keyboard alternative. |
| 2.5.2 | Pointer Cancellation | ✅ Pass | — | Click handlers fire on click, not mousedown. |
| 2.5.3 | Label in Name | ⚠️ Partial | 🟡 | Custom `<div class="win-btn">` close/min buttons use `✕` / `−` as visible text but have no accessible name. |

### 3. Understandable

| # | Criterion | Status | Severity | Finding |
|---|---|---|---|---|
| 3.1.1 | Language of Page | ✅ Pass | — | `<html lang="en">` set. |
| 3.2.1 | On Focus | ✅ Pass | — | Nothing surprising on focus. |
| 3.2.2 | On Input | ✅ Pass | — | Input changes don't trigger navigation. |
| 3.3.1 | Error Identification | N/A | — | No forms with validation. |
| 3.3.2 | Labels or Instructions | ❌ Fail | 🟡 | `#share-search` input has placeholder but no `<label>` or `aria-label`. |

### 4. Robust

| # | Criterion | Status | Severity | Finding |
|---|---|---|---|---|
| 4.1.2 | Name, Role, Value | ❌ Fail | 🔴 | Windows are visual dialogs but lack `role="dialog"`, `aria-labelledby`, `aria-modal`. Start menu lacks `role="menu"` + `aria-expanded` on the button. Minesweeper grid has no `role="grid"`/`role="gridcell"`. Paint canvas has no textual fallback. Winamp controls are `<button>` elements (good) but have no `aria-label` describing "play", "previous", etc. — only emoji/glyph content. |
| 4.1.3 | Status Messages | ❌ Fail | 🟡 | Animated counters, minesweeper timer, winamp EQ, SBShare progress bars update without `aria-live` announcements. |

---

## Non-WCAG accessibility concerns

These aren't scored by WCAG 2.1 AA but are important:

- **`prefers-reduced-motion` not respected** — Clippy wiggle, Winamp EQ animation, scrolling marquee, progress bar transitions, bouncing screensaver, and counter animations all ignore user motion preferences. 🟠 **Serious for users with vestibular disorders.**
- **Auto-starting screensaver** — fires after 45s idle with movement and color-flash on wall hits. Could cause issues for photosensitive users. 🟠
- **Clippy auto-appears** — pops in automatically 2.5s after load with no way to pre-dismiss. 🟡
- **`user-select: none` on `<body>`** — prevents selecting any text, which affects users who rely on text selection for translation tools, read-aloud, or copying. 🟠
- **Emoji-as-icon semantics** — screen readers will read "page emoji", "bomb emoji", "broom emoji", etc. Icons need real accessible names.
- **No page-level skip-to-content or quick-nav** — even sighted keyboard users must tab through ~50 elements.

---

## Recommended action plan

### If going with **Accessible View toggle** (recommended):

1. Add a prominent, keyboard-accessible banner at the very top of the current page:
   ```html
   <a href="south_bend_accessible_report.html" class="accessible-link">
     ♿ View as an accessible document
   </a>
   ```
2. Build `south_bend_accessible_report.html` as a standard HTML document:
   - Proper heading structure (`<h1>` report title → `<h2>` sections)
   - Semantic landmarks (`<header>`, `<main>`, `<section>`, `<footer>`)
   - Same content as Welcome / Services / Stats / What Changed / ReadMe — no windows, no drag, no games
   - Keyboard-native, screen-reader-friendly, reflowable to 320 px
3. Test the accessible version with axe, Lighthouse, and screen readers (NVDA/JAWS/VoiceOver).
4. In the source HTML, add a note for assistive tech: `<p class="sr-only">This page is a stylized interactive experience. A fully accessible version is linked at the top.</p>`

### If retrofitting the XP version (higher effort):

Priority order:
1. 🔴 Add `prefers-reduced-motion` guards to every animation
2. 🔴 Make desktop icons focusable (`tabindex="0"`, keyboard Enter handler, role="button", aria-label)
3. 🔴 Add `role="dialog"` / `aria-labelledby` / `aria-modal="true"` on all `.win` elements
4. 🔴 Add visible `:focus-visible` styles to every interactive element
5. 🟠 Fix color-contrast failures (list above)
6. 🟠 Remove `user-select: none` from body
7. 🟠 Remove `overflow: hidden` from body; allow scroll/zoom
8. 🟠 Add `<label>` or `aria-label` to `#share-search`
9. 🟠 Add skip link + landmark regions
10. 🟠 Add `aria-live` on dynamic counters
11. 🟡 Add keyboard alternatives for Minesweeper flag (right-click) and window drag
12. 🟡 Add `aria-label` to emoji-only buttons
13. 🟡 Don't auto-open Clippy; require interaction; make closable via Esc

---

## Methodology notes

This audit is a **heuristic code review** — not a conformance test. It did not include:
- Actual screen reader testing (NVDA, JAWS, VoiceOver, TalkBack)
- Automated tooling (axe-core, WAVE, Lighthouse)
- Keyboard-only user testing
- Testing at 200% zoom / 400% zoom
- Testing in browsers other than Chrome
- Testing with Windows High Contrast mode

**For a defensible AA certification**, run axe-core + manual screen-reader passes on the final (accessible) version.

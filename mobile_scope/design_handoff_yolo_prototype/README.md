# Handoff: Yolo — Full App Flow Prototype

## Overview
An interactive, click-through prototype of the Yolo app covering the full MVP flow: onboarding, home, group creation, group home, the plan-creation flow (kickoff → survey → waiting room → AI suggestion → final poll → plan locked), post-event wrap-up, and profile/availability. Built to match Yolo's existing PRD, screen plan, and SwiftUI source (`Theme.swift`, `Models.swift`, component files) in this repo.

## About the Design Files
The bundled file (`Yolo.dc.html`) is a **design reference built in HTML/React**, running inside a simulated iPhone frame (`ios-frame.jsx`) — it is a prototype for demonstrating look, flow, and interaction, **not production code to copy directly**. The target codebase is native **Swift/SwiftUI (iOS 17+)**, per `PRD.md` and the existing `Yolo/Sources/` project. The task is to recreate each screen as a SwiftUI `View`, reusing the existing `Theme.swift` tokens and `Components/` (AvatarView, StatusPill, YoloButton, ChipButton) already in the codebase — do not introduce new colors, fonts, or component patterns.

## Fidelity
**High-fidelity.** Colors, spacing, and copy are final and pulled directly from `Theme.swift` / `Models.swift` / `PRD.md`. Treat hex values and copy strings as exact. Icon treatment is simplified in the HTML prototype (text-forward, no SF Symbols) — for the real app, use SF Symbols per the existing screen plan (icons noted per screen below where the plan specifies one).

## Design Tokens (from `Yolo/Sources/Design/Theme.swift` — already in the codebase)
- Background: `#000000` (pure black)
- Surface: `#111111` (yoloSurface), `#1C1C1C` (yoloSurface2), `#242424` (yoloSurface3)
- Border: `#2A2A2A` (yoloBorder), gold border `#C9A84C` @ 22% opacity (yoloBorderGold)
- Gold (single accent, primary CTAs + key data only): `#C9A84C`, light `#E3C16A`, dim `#6B5520`
- Text: white primary, `#8A8A8A` secondary (yoloTextSecondary), `#4A4A4A` tertiary (yoloTextTertiary)
- Status colors: green `#30D158`, amber `#FFD60A`, red `#FF453A`, blue `#0A84FF`
- Radius: sm 8, md 12, lg 16, xl 22, pill 100 (YoloRadius)
- Spacing: xs 4, sm 8, md 16, lg 24, xl 32, xxl 48 (YoloSpacing)
- Type: system font (SF), bold uppercase 11px tracked labels for section headers, 16px semibold for buttons
- Voice: **all copy lowercase**, no emojis, SF Symbols only for icons
- Card style: `.yoloCard` = surface bg + border(0.5px, yoloBorder) + radius lg; `.yoloGoldCard` swaps border for gold @22%

## Screens

### 1. Splash
Full black screen, gold "yolo." wordmark centered (italic serif/script feel — real app should use the logo asset in `/logos/yolo_logo_final.png`). Auto-advances to onboarding after a short hold.

### 2. Welcome (onboarding carousel)
3 full-screen cards, large centered lowercase copy, dot pagination (active dot = gold pill, inactive = small gray dot), bottom primary button "next →" / "let's go →" on last card. Copy (verbatim, from `03_screen_plan.md`):
1. "the gc talks big. yolo makes it real."
2. "everyone votes. ai picks. you show up."
3. "no more chasing people for e-transfers."

### 3. Phone Auth
Title "sign in", single phone-number text field (surface2 bg, border, radius 12), primary gold button "continue", ghost button "continue with apple" below. Real flow: SMS OTP after phone submit (out of scope for this prototype — simplified to direct advance).

### 4. Profile Setup
Dashed-border circular photo placeholder (tap to upload, skippable), display name field, city field, primary button "done".

### 5. Home ("your groups")
- Header: user avatar (initial in gold circle, tap → Profile) + "your groups" title + alerts affordance
- Optional dashed gold banner if a group has been idle 3+ weeks: "{group} hasn't linked in a while / nudge them?"
- Group card feed: each card = name, status pill (colored dot + label: planning/amber, locked in/green, happened/gray, dead/red, idle/border-gray), stacked member avatars (max 4 + overflow), last-activity text, gold link-count stat. Tap card → Group Home.
- FAB bottom-right: "+ new group" → Create Group

Mock groups (from `Models.swift`, already in codebase):
- "the usual suspects" — 5 members, planning, "arh wants to plan something", 14 links
- "cottage crew" — 3 members, locked in, "locked in for saturday", 6 links
- "film club" — 3 members, idle, "last linked 3 weeks ago", 22 links

### 6. Create Group
Text field "crew name" + 3 tappable suggested-name chips, member picker (avatar chips, tap to toggle, dimmed when unselected, min 2), vibe single-select chips (we go out / outdoorsy / homebody types / chaotic mix), primary button "create group".

### 7. Group Home
Back chevron + group name/member count header, big primary "start a plan" button, recent-activity feed (3 text cards), gold-bordered stat card "you've linked up N times", mini accountability leaderboard (most reliable + biggest flake member, name/title + show-up % colored green/red), ghost button "check availability" → Profile's availability section.

### 8. Kickoff ("what are we tryna do?")
2×3 grid of activity tiles: food / activity / going out / movie / trip / surprise me (single-select, gold outline+tint when selected). Timeframe chip row: this weekend / next week / tonight / flexible (single-select). Primary button "send it" (disabled/40% opacity until both selected).

### 9. Survey ("what are you feeling?")
Same 6 activity chips but **multi-select**. Budget chip row ($0–20 / $20–50 / $50–100 / $100+, single-select). 7-day mini week strip (mon–sun, multi-select toggle). Effort segmented control (low/medium/high, single-select). Primary button "submit".

### 10. Waiting Room
Row of member avatars — full opacity + green checkmark badge if responded, dimmed/gray if pending. Deadline text "answers due by fri 8pm". Secondary gold-outline button "poke the slackers" (increments responded count by one per tap, simulating a nudge). When all responded, primary button "see suggestions" appears.

### 11. AI Suggestion ("yolo picked 3")
3 cards, each: title, gold cost-per-person, gray "why" reasoning line, small tag chips. Tap to select (gold border highlight, single-select). Primary button "lock this in" (disabled until one selected).

Suggested copy (mock/example — replace with real AI output when backend exists):
1. **dinner + bowling** — "half the group wanted food, half wanted an activity, so we split the difference." — $30/person — casual, indoor, groups
2. **sunset patio drinks** — "most of you said low effort, high vibes this week." — $25/person — chill, outdoor, day-drink
3. **movie + late-night diner** — "two of you can't do $50+ right now, so this stays cheap." — $18/person — budget, indoor, chill

### 12. Final Poll ("you in?")
Gold-bordered summary card of the chosen plan. 3-way vote buttons for the current user: yes / maybe / can't make it (single-select, colored per choice: green/amber/red). Live roster below showing every member's name + vote status by color. Header line "live results · N% yes". When the current user votes "yes", a primary button "we're locked in →" appears (in the real app this should trigger at the 80% auto-lock threshold from the PRD, not just on the current user's vote — the prototype simplifies this for demo purposes).

### 13. Plan Locked
Centered gold checkmark badge, "it's official." headline, gold-bordered summary card (plan title, day, stacked avatars of who's in). 3 stacked buttons: "add to calendar" (ghost), "share plan card" (gold outline), "open group chat" (ghost — deep-links to the group's existing iMessage/WhatsApp thread, no in-app chat). Small link at the bottom to jump to Post-Event for demo purposes.

### 14. Post-Event ("how'd it go?")
Roll-call list: each member row with "showed" / "flaked" toggle buttons (green/red tint when selected) — feeds the accountability system (show-up rate, flake count). 5-star tap-to-rate row. 2×2 photo grid of add-photo placeholders (striped pattern + "add photo" label — wire to real photo picker). Primary button "save recap".

### 15. Profile + Availability
Header avatar + name + title/rep (e.g. "the anchor"), 3 stat cards (total links, show-up rate, group count). 7×3 availability heatmap grid (days × morning/afternoon/evening), tap any cell to toggle free/not-free (gold fill = free). Settings list rows: notifications, location privacy, connected accounts (chevron affordance, currently non-functional).

## Interactions & Behavior
- All navigation is push/pop on a simple screen stack (back chevron pops to the previous screen) — maps directly to SwiftUI's `NavigationStack` + `fullScreenCover`, matching the PRD's stated architecture.
- Every selection state (tiles, chips, votes) is single tap, immediate visual feedback via border/fill color change — no separate confirm step.
- No loading or error states are represented; all data is mock/in-memory per the MVP's "no backend" scope.
- No animations are implemented in the prototype; per `PRD.md` §6, add: spring bounce on tile/chip selection, and confetti + gold flourish on the Plan Locked screen ("one animation per moment," using the existing `YoloSpring` presets already defined in `Theme.swift`).

## State Management
Mirrors what `AppState.swift` should hold:
- Current screen / navigation stack
- Selected group id
- In-progress plan draft: activity type, timeframe, survey answers (picks, budget, days, effort), per-member response tracking, AI suggestion selection, per-member poll votes
- Post-event: per-member roll-call status, star rating, photos
- Profile: name, city, per-slot availability grid

## Assets
No new image assets. Existing brand asset `logos/yolo_logo_final.png` should be used on Splash/Welcome instead of the prototype's styled text wordmark. No icons are drawn in the prototype (kept text-forward, matching the source `MemberTitle`/`ActivityType` string values) — apply SF Symbols per the icon names already declared in `Models.swift` (`ActivityType.icon`, `PlanResponse.EffortLevel.icon`).

## Files
- `Yolo.dc.html` — the full clickable prototype (open directly in a browser)
- `ios-frame.jsx` — the iPhone device-frame shell the prototype renders inside (visual reference only, not for reuse in Swift)

# Yolo — Product Requirements Document

**Version:** 1.0  
**Status:** MVP  
**Platform:** iOS 17+

---

## 1. Problem

Friend groups want to hang out. They say so constantly in the group chat. But plans die because:

1. Nobody wants to be the person who forces the decision
2. RSVPing costs nothing, so people say yes and bail
3. Decision fatigue from "where should we go / when are you free / who's in" loops
4. The same one or two people always do all the organizing — until they stop

The result: years-long friend groups that almost never actually link up, despite everyone claiming they want to.

---

## 2. Solution

Yolo is a group planning app that treats commitment as the product. It removes every friction point between "we should hang" and "here's where we're going Saturday."

The core mechanic: the app proposes a specific plan (not a blank form), collects votes, and automatically locks it when enough people confirm. Opting out is visible to the group. That visibility — not features — is what actually closes plans.

**Tagline:** helping plans escape the group chat.

---

## 3. Users

**Primary:** Gen Z (18–26) in existing close friend groups. They are not looking for new friends — they have friends they want to see more. The app is always opened in response to a group chat conversation about linking up.

**Secondary:** Millennial friend groups (27–35) who face the same coordination collapse as jobs and kids make scheduling harder.

**Non-user:** anyone looking to meet strangers, find events, or post content publicly.

---

## 4. Core User Flow (MVP)

```
Group Chat → "we should link" → one person opens Yolo
    → GroupHomeView
    → KickOffView        (activity type + timeframe)
    → SurveyView         (individual preferences: budget, days, effort)
    → WaitingRoomView    (group waits for all responses)
    → AISuggestionView   (3 ranked options with reasoning)
    → FinalPollView      (yes / maybe / can't make it)
    → PlanLockedView     (it's official)
    → PostEventView      (roll call + rating + photos)
```

Each screen is a full-screen moment, not a step in a wizard. The transition between screens should feel like narrative progress, not form-filling.

---

## 5. Feature Requirements

### 5.1 Groups

| Feature | Priority | Description |
|---|---|---|
| Group card feed | P0 | Home screen shows all groups with status, last activity, member count |
| Group creation | P0 | Name + vibe selection, auto-generates invite link |
| Group status | P0 | planning / locked in / happened / idle / dead — visible everywhere |
| Accountability leaderboard | P0 | Show-up rate and flake count per member, ranked |
| Member profiles | P1 | Tap any member to see full stats, rep bars, plan history |
| Group invite | P1 | Shareable link card, copy button, iMessage shortcut |
| Availability heatmap | P1 | 7-day × 3-slot grid showing who's free when |

### 5.2 Planning Flow

| Feature | Priority | Description |
|---|---|---|
| Activity type selection | P0 | food / activity / going out / movie / trip / surprise me |
| Timeframe selection | P0 | this weekend / next week / this month / flexible |
| Preference survey | P0 | Budget tier, available days, effort level |
| Waiting room | P0 | Real-time response tracking with member dots |
| AI suggestion engine | P0 | 3 ranked options with venue, cost, reasoning |
| Final poll | P0 | Three-way vote (yes/maybe/can't), auto-lock at 80% yes |
| Plan locked screen | P0 | Confirmation moment with confetti, calendar add, share |

### 5.3 Accountability System

| Feature | Priority | Description |
|---|---|---|
| Show-up rate | P0 | Percentage of confirmed plans attended |
| Flake count | P0 | Total confirmed → no-show count, visible to group |
| Member titles | P0 | anchor / wildcard / ghost / hypeman / planner / surprise guest |
| Nudge button | P1 | Poke members who haven't responded |
| Rotating planner | P2 | System tracks who planned last, suggests next person |

### 5.4 Post-Event

| Feature | Priority | Description |
|---|---|---|
| Roll call | P1 | Who showed vs who flaked, updates accountability scores |
| Star rating | P1 | 1–5 visible to the whole group |
| Photo album | P1 | Per-group photo memory, organized by plan |
| Plan recap card | P2 | Shareable image: plan name, date, who came, rating |

### 5.5 Virality

| Feature | Priority | Description |
|---|---|---|
| Invite link | P0 | Every group has a unique join link |
| Shareable plan card | P1 | Locked plan generates a shareable image artifact |
| Web preview | P2 | yolo.app/plan/[id] opens a web page no app required |
| Soft deposit | P2 | Hold $5 on RSVP, refunded if you show — reduces flaking ~60% |

---

## 6. Design Principles

**Black first.** Pure black backgrounds (#000), not dark grey. The darkness is the canvas; gold (#C9A84C) is the only warm element.

**Gold is sacred.** Only primary CTAs and key data points get gold. If everything is gold, nothing is.

**Lowercase always.** Every string in the app is lowercase. It's a brand voice decision, not a bug.

**No emojis.** SF Symbols only. The app looks like a Bloomberg terminal designed by Supreme — precise, confident, a little cold.

**One animation per moment.** Confetti on plan lock. Spring bounce on selection. Not both, not everywhere.

**Cards over lists.** Content lives in contained surfaces with consistent border treatment. No raw list rows.

---

## 7. Technical Architecture (MVP)

| Layer | Choice | Reason |
|---|---|---|
| Language | Swift / SwiftUI | iOS-native feel, fast iteration |
| State | @Observable + AppState | iOS 17+, no boilerplate |
| Navigation | NavigationStack + fullScreenCover | Planning flow needs full-screen transitions |
| Data | In-memory mock | No backend complexity in MVP |
| AI | LLM API (suggestions) | Aggregation + ranking of preferences |
| Backend (v2) | Supabase | Auth (phone OTP), realtime, DB |
| Payments (v2) | Stripe | Soft deposit mechanism |
| Maps (v2) | MapKit + Google Places | Venue suggestions with travel times |

---

## 8. Metrics (post-launch)

| Metric | Target | Why |
|---|---|---|
| Plans completed / group / month | ≥1 | Core loop health |
| Plan lock rate | >60% of started flows | Conversion |
| D7 retention | >40% | Habit forming |
| Invite link CTR | >25% | Viral coefficient |
| Flake rate after seeing score | <15% | Accountability working |

---

## 9. Roadmap

### v1.0 — MVP (current)
Full planning flow with mock data. All screens navigable. Accountability visible. Share + invite working.

### v1.1 — Real Data
Supabase backend. Phone auth. Real groups with real members. Push notifications for plan events.

### v1.2 — Virality
Web preview for plan links. Shareable plan card image generation. Invite page (no app required for guests).

### v1.3 — Accountability 2.0
Soft deposit ($5 hold on RSVP). Rotating planner mechanic. Group streak.

### v2.0 — Monetization
In-app payments + cost split. Venue booking affiliate. Big Trip mode.

---

## 10. Out of Scope (MVP)

- Public events / discovery
- Stranger connections
- Chat / messaging inside the app
- Map views / venue photos
- Payment processing
- Push notifications
- Web app

---

## 11. Open Questions

1. What triggers the AI suggestions — pure preference matching, or does location/availability factor in?
2. Should flake scores be visible to people outside the group, or only within?
3. How do we handle the first-time user who has no groups yet — what's the empty state that converts?
4. Soft deposit: which payment processor, and how do we handle disputes?
5. Is the rotating planner opt-in or automatic?

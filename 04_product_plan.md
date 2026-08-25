# Yolo — Deep Product Plan

Research sources: Partiful growth analysis (Time 100 2025, CNBC), Sacra, consumer app retention studies, commitment device psychology research, Partiful vs Luma comparison.

---

## What the Research Says

### Why Partiful Blew Up (400% YoY growth, 7M users, zero paid ads)
1. **Product-led virality** — every invite is a mini ad. Guest sees a beautiful invite page, gets nudged to download. Yolo needs this: every plan link should be shareable without requiring the recipient to have the app.
2. **Personality over utility** — Partiful didn't win on features, it won on *feeling*. The app has a voice. Yolo's "lighthearted accountability" is the equivalent — lean into it hard.
3. **Post-event memory** — shared photo album after the event is a massive retention loop. People come back to relive it.
4. **Text blasts** — organizer can ping everyone via SMS-style notification. Not push. Text.

### Why Group Plans Actually Die (psychology research)
1. **Diffuse accountability** — "the group" is responsible = nobody is responsible
2. **No real skin in the game** — RSVPing costs nothing, flaking costs nothing
3. **Decision paralysis** — too many options, no tiebreaker, everyone deferring to everyone
4. **The planner always being the same person** — exhausting, kills groups over time

### What Gen Z Actually Wants (2025-2026 research)
- Close-friends first, not broadcast social
- Coordination in private, not public
- Real presence (who's actually going), not likes
- Low-friction RSVP (no app required for guests)
- Post-event content loop (photos, memories)

---

## Feature Priority Stack

### Tier 1 — Virality & Core Loop (build now)
These directly drive downloads and retention.

| Feature | Why | Partiful parallel |
|---|---|---|
| Shareable invite link (web preview, no app required) | Every plan becomes a growth vector | Partiful's #1 growth mechanism |
| Flake score visible to the whole group | Real social stakes, not just a counter | — |
| Post-event photo album | Retention loop, people revisit | Partiful post-event album |
| "Rotating planner" mechanic | Solves the same-person-always-plans problem | — |
| Soft deposit on RSVP (hold $5, refunded if you show) | Hard commitment device, reduces flaking by ~60% | — |

### Tier 2 — Engagement & Stickiness (build next)
| Feature | Why |
|---|---|
| Group hangout streak | Habit formation, Duolingo-style |
| Availability heatmap (calendar sync) | Eliminates the "when is everyone free?" text |
| Weather alerts for outdoor plans | Prevents last-minute cancellations |
| Surprise me mode (AI picks the whole thing) | Low friction, viral moment |
| Pre-event hype countdown (home screen widget) | Daily re-engagement |
| "Who else is going?" social proof on invite | FOMO driver |

### Tier 3 — Monetization (v2)
| Feature | Why |
|---|---|
| In-app payments + split | Stripe integration, take 1.5% |
| Venue booking / reservations | Affiliate revenue |
| Big Trip mode (cottage, travel) | Higher LTV users |

---

## UI Problems to Fix (current state)

1. **Group cards are too thin** — need a proper visual identity per group (gradient cover, not just a 3px line)
2. **Nothing is tappable** — every button should navigate somewhere or show a sheet
3. **No empty states** — new user sees nothing, drops immediately
4. **No notifications feel** — the app feels static, needs animated activity indicators
5. **Profile tab is placeholder** — needs real stats and rep system
6. **No "just arriving" moment** — the first time you open the app after a plan locks should feel special
7. **Typography hierarchy weak** — group name and last activity look too similar in weight

---

## Navigation Map (fully wired)

```
HomeView (tab bar)
├── GroupsFeedView
│   ├── GroupCard → GroupHomeView
│   │   ├── "start a plan" → KickOffView → SurveyView → WaitingRoomView → AISuggestionView → FinalPollView → PlanLockedView
│   │   ├── "who's free?" → AvailabilityView (NEW)
│   │   ├── "invite" → InviteView (NEW)
│   │   └── accountability row → MemberProfileView (NEW)
│   └── FAB → CreateGroupView
├── ActivityView
│   ├── nudge banners (interactive)
│   └── plan history cards
└── ProfileView
    ├── edit profile sheet
    └── settings sheet

PlanLockedView
└── → PostEventView (NEW, shown after event time passes)
    └── → PhotoAlbumView (NEW)
```

---

## Implementation Order for This Session

1. Wire all existing buttons to real destinations
2. Add `AvailabilityView` — who's free this weekend grid
3. Add `InviteView` — shareable link card with QR code
4. Add `PostEventView` + `PhotoAlbumView` — post-plan memory screen
5. Add `MemberProfileView` — tap any member to see their full stats
6. Redesign group cards with proper cover gradient + visual weight
7. Fill in `ActivityTabView` with real notification-style feed
8. Fill in `ProfileTabView` with rep system and real stats
9. Add skeleton loading states

---

## The Viral Moment Yolo Needs

Like Partiful's invite pages, Yolo needs one shareable artifact that spreads the app.

**The Yolo Plan Card** — when a plan locks, it generates a shareable image:
- Black background, gold "yolo." watermark
- Plan name, date, venue, who's going (stacked avatars)
- A URL: `yolo.app/plan/[id]` that opens a web preview
- Shareable to Instagram Stories, iMessage, anywhere

This is the #1 growth move. Every locked plan = potential new users.

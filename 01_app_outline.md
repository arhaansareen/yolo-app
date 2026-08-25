# Yolo — App Outline

**Mission:** Reduce friction in group planning + increase actual follow-through on plans.

## What is Yolo?

Yolo's basically for when the gc talks a big game about "we should link up" and it just... never happens. Everyone throws in what they're tryna do, and the app's AI figures out what most people actually want instead of the same 3 people arguing in the chat forever. Once y'all pick something, everyone drops their location and it finds a spot that's actually fair for everyone to get to, not just closest to whoever suggested it. Then it's a quick yes/no poll, and if it's a bigger thing like a cottage trip, the app helps handle the whole booking/payment side so nobody's stuck chasing people for e-transfers. And if you say you're pulling up and then flake last minute, there's a lil lighthearted way the app keeps you accountable for that — plus it tracks how many times the group's actually linked up over time. Basically just trying to make plans real instead of just something we talk about.

## Core Flow

1. **Create a group** (GC-style crew)
2. **Quick survey** — everyone says what they want to do
3. **AI aggregates** responses → suggests top choice(s), can resolve conflicts (e.g. half want food/half want activity → suggest hybrid like dinner + bowling)
4. **Live location** from everyone → app triangulates a spot that's fair for the group based on **real travel time** (not just raw distance)
5. **Poll** — yes/no confirmation from the group
6. **Big trip mode** (e.g. cottage trip) — helps handle financial/booking logistics
7. **Accountability tracking** — who actually pulled up vs. said yes then flaked, who's latest via calendar/notifications, lighthearted (not serious) punishment/tracking system (streaks, "L" counter type stuff — nothing that actually punishes people)

## Additional Feature Ideas (not yet prioritized)

### Speed from idea → plan
- Auto-suggest plans based on group's past hangout patterns
- Rotating "organizer" role so it's not always the same person
- Availability heatmap (auto-sync calendars/free-busy instead of texting back and forth)
- "Surprise us" low-effort button — picks something based on past preference/budget/location

### Motivation / follow-through
- Hype notifications / countdowns building up to the event
- Group "streaks" for hangouts actually happening
- Upfront cost transparency per person before commit
- Small deposit/Venmo tied to RSVP, refunded if you show up (alternative to social punishment)

### AI usefulness
- Conflict resolution, not just aggregation
- Flagging logistics problems early (e.g. venue closes before half the group can arrive)

### Accountability / money / other (latest additions)
- Punishment can happen for people who cancel last minute and ruin the plan
- All payments can be made directly on the app to make group costs easier
- Link tracker — tracks how many hangouts ("links") the group has done over time
- Weather issue flagging — surface weather risks for outdoor plans ahead of time

## Decided
- ✅ Name: **Yolo**
- ✅ Triangulation = travel time, not raw distance
- ✅ Punishment mechanic = lighthearted, not harsh/serious

## Open Questions
- What's the actual MVP — planning tool or accountability tool first?

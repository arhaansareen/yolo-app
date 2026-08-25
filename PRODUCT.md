# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Users

Gen Z friend groups (18–26). The user is always inside an existing social circle — a university friend group, housemates, co-workers — not a stranger. They are in the group chat watching plans dissolve. Primary device: iPhone, always. Usage moments: commuting, lying in bed, waiting for friends.

## Product Purpose

Yolo turns "we should link" into a confirmed plan. It does not replace the group chat — it picks up where the chat stalls. A single tap starts a planning flow; the app aggregates everyone's preferences, generates AI-ranked options, and locks the plan once consensus is reached. Success = a confirmed event on the calendar with everyone's RSVP.

## Positioning

Every other coordination tool (Partiful, Doodle, iMessage threads) asks people to agree before the plan exists. Yolo does the opposite: it proposes a specific plan first, then collects votes. The app assumes you will go — opting out costs more social capital than opting in. That asymmetry is what actually closes plans.

## Operating Context

- Used in idle moments, not at a desk
- Always opened in response to a group chat conversation
- Users are simultaneously in the group chat and in the app
- Decision window is 24–48 hours; plans that take longer die
- Peer accountability is the primary motivation mechanism (flake scores are public)

## Capabilities and Constraints

- Group planning flow: KickOff → Survey → WaitingRoom → AI Suggestion → Final Poll → Plan Locked
- Availability heatmap across the group
- Shareable invite link (Partiful-style growth vector)
- Member accountability scores (show-up rate, flake count, title)
- Post-event recap + photo album
- No backend yet — all mock data, in-memory state
- iOS 17+, SwiftUI only
- No payments, no map integration in MVP

## Brand Commitments

- Name: yolo
- Voice: lowercase everywhere, dry and confident, never corporate
- Palette: pure black (#000) backgrounds, gold (#C9A84C) as the single action color, white for primary text
- No emojis anywhere — SF Symbols only
- Tagline: "helping plans escape the group chat"
- Feel: exclusive, members-only, slightly irreverent — like a black card, not a party app

## Evidence on Hand

- 04_product_plan.md: Partiful growth research (400% YoY, 7M users, zero paid ads), commitment-device psychology, Gen Z coordination research
- No real user interviews yet; all positioning is hypothesis-driven

## Product Principles

1. **Specificity closes plans.** A concrete proposal beats an open question. Always show an option, never an empty form.
2. **Social stakes are the feature.** Flake scores, accountability boards, and public RSVPs exist because embarrassment works better than reminders.
3. **Every artifact is a growth vector.** Invite cards, plan lock screenshots, post-event recaps — each one should be shareable and beautiful enough that people screenshot it unprompted.
4. **Speed over completeness.** A 30-second plan > a perfect plan that takes 10 minutes. Reduce every step; default every field.
5. **The group, not the individual.** Design for the social dynamics of a group, not the preferences of a single user.

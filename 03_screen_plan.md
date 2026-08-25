# Yolo — iOS Screen Plan

**Vibe:** Members-only luxury meets group chat chaos. Black base, gold accents, lowercase everything, no caps energy. SwiftUI, iOS 17+.

---

## 0. Launch / Splash
- Black screen, gold "yolo." logo fades in centered
- Short hold → auto-navigates to Onboarding or Home

---

## 1. Onboarding (first-time only)

### 1A. Welcome
- Full black screen, gold logo at top
- 3–4 swipe cards explaining the concept:
  - "the gc talks big. yolo makes it real."
  - "everyone votes. ai picks. you show up."
  - "no more chasing people for e-transfers."
- Bottom CTA: "let's go →"

### 1B. Sign Up / Log In
- Phone number entry (primary) → SMS OTP
  - Or "continue with apple" as secondary
- Minimal UI — just the input, no clutter
- No email/password

### 1C. Profile Setup
- Upload photo (optional, can skip)
- Set display name (lowercase enforced visually)
- Set your city / home base (used for travel time calculations later)
- One-tap done

---

## 2. Home — "your groups"

- List of active groups (cards)
  - Group name, member avatars (stacked), last activity blurb
  - Status pill: "planning 🟡", "locked in ✅", "happened ✓", "dead 💀"
- FAB (floating action button): "+ new group" or "join group"
- Top: avatar of user + notification bell
- Empty state: "no groups yet. start one." with gold dashed border card
- **New idea:** "suggested link-up" banner — if your group hasn't hung out in 3+ weeks, app nudges you at top

---

## 3. Create Group

### 3A. Name Your Crew
- Text field: "what do you call yourselves?"
- Character limit, emoji allowed
- Suggested names (AI-generated based on nothing, just fun vibes)

### 3B. Add Members
- Search by phone number or username
- Or share a link/QR code (invite card that looks like an exclusive event invite)
- Members appear as avatar chips as they're added
- Min 2, soft cap at ~20

### 3C. Group Vibe (optional)
- Quick picks: "we go out 🍸", "we do outdoorsy stuff 🏕️", "we're homebody types 🛋️", "chaotic mix 🌀"
- Used to bias AI suggestions later
- Can skip / set later

---

## 4. Group Home

The main hub once you're inside a group.

- Group name + members row (tappable → member list)
- **"start a plan"** — big primary button
- Recent activity feed:
  - "arh suggested linking up"
  - "3/5 voted yes on the plan"
  - "you linked up last on july 4 🔥"
- Link tracker: "you've linked up X times together" — subtle gold stat
- Accountability section: mini leaderboard — most reliable vs. biggest flake (lighthearted labels)
- **New idea:** "availability check" shortcut — one tap to see who's free this weekend without starting a full plan

---

## 5. Planning Flow

### 5A. Kick Off a Plan
- "what are we tryna do?" — open text or category tiles:
  - 🍕 food  🎳 activity  🍸 going out  🎬 movie  🏕️ trip  🎲 surprise me
- Set rough timeframe: "this weekend", "next week", "tonight", "TBD"
- Optional: set a deadline for responses ("need answers by friday 8pm")
- Sends push notifications to all group members

### 5B. Member Survey (each member's view)
- Each member gets notified and opens this
- "what are you feeling?" — multi-select from tiles + free text option
- Budget range slider (rough: $0–20 / $20–50 / $50–100 / $100+)
- Availability: tap days on mini week calendar
- One vibe rating: "how much effort can you give this?" (low/medium/high)
- Submit → see live response counter ("3/5 responded")

### 5C. Waiting Room
- Shows avatar circles — filled = responded, grey = pending
- Countdown timer if a deadline was set
- Nudge button: "poke the slackers" → sends a ping to non-responders
  - **New idea:** auto-nudge 2hrs before deadline, with a funny message

### 5D. AI Suggestion Screen ⭐
- AI processes all responses → shows top 1–3 plan suggestions
- Each card: activity name, why it works ("4/5 wanted food, 3/5 wanted something chill"), estimated cost/person, vibes tags
- Conflict resolution: "half wanted food, half wanted an activity → we found dinner + bowling"
- Tapping a card expands it with more detail
- "not feeling these?" → re-roll (limited — 2 re-rolls per session)
- Group creator picks one OR puts it to a vote
- **New idea:** "why this?" explainer — tap to see the AI's reasoning in plain english

---

## 6. Location & Spot Finding

### 6A. Share Location
- After plan type is chosen, everyone shares live location (or enters home address for privacy)
- Map view showing all members as dots
- Privacy option: "use my neighborhood, not exact location"

### 6B. Spot Suggestions
- App calculates travel time from each member → finds the fairest meeting point
- Shows 3–5 venue suggestions (pulls from Google Places / Yelp):
  - Name, distance/travel time per person, rating, price range, photo
- Color-coded: green = fair for everyone, yellow = slight advantage to some
- Tap venue → full detail card with map, hours, menu link
- **New idea:** "vibe match" score — how well the venue matches the group's stated vibe preferences

### 6C. Final Poll
- Simple yes/no: "are you in for [plan] at [spot] on [day]?"
- Live results show as people vote (names shown, not anonymous)
- Threshold: if 80%+ yes → auto-lock
- If someone votes no → optional "why not?" quick reply (too far, too expensive, can't make it)
- **New idea:** "soft yes" option — "i'll try to make it" counted separately from hard yes

---

## 7. Plan Locked ✅

- Confirmation screen: confetti, gold animation
- Summary card: what, where, when, who's in
- Add to calendar button
- Group chat deeplink (just opens their existing iMessage/WhatsApp gc)
- Share card: exportable image recap of the plan (good for posting/sharing)
- Countdown widget support (iOS home screen widget showing T-minus to plan)
- **New idea:** pre-plan hype notifications — "it's tomorrow 🔥", "happening in 2 hours"

---

## 8. Big Trip Mode 🏕️

Unlocked when plan type = trip (cottage, travel, multi-day).

### 8A. Trip Setup
- Trip name, dates, destination (rough or specific)
- Estimated total cost / per-person breakdown

### 8B. Task Splitter
- Auto-generated task list: "book the Airbnb", "coordinate carpool", "buy groceries"
- Assign tasks to members
- Completion checkboxes — group can see progress

### 8C. Group Payments
- Each person owes X
- Pay via Apple Pay / card in-app
- Running total of who's paid, who hasn't
- Automated reminders for unpaid members
- Organizer receives funds or funds held until trip
- **New idea:** receipt splitter — upload a photo of a receipt, split it automatically

### 8D. Trip Timeline
- Day-by-day itinerary (auto-suggested or manually built)
- Shared packing list
- Emergency contact + address card for the trip

---

## 9. Post-Plan / Accountability

### 9A. "Did You Actually Show Up?"
- After plan time passes, each member gets: "did the plan happen?"
- Quick reaction: ✅ we linked / ❌ it got cancelled / 😬 some people flaked
- If flakes reported → tag who flaked (lighthearted, not mean)

### 9B. Wrap Screen
- "you linked up! 🔥" — recap card
- Add photos from the hangout (group album)
- One-tap rating: how was it? (fire / solid / mid / disaster)
- Link count goes up for the group

### 9C. Accountability Stats (per member, per group)
- "showed up X/Y times"
- "flaked X times"
- Titles: "the anchor ⚓", "the wildcard 🎲", "the ghost 👻", "the hypeman 📣"
- **New idea:** "redemption arc" — if you've flaked 3x and then show up, you get a special badge

---

## 10. Profile

- Avatar, display name, city
- Your stats across all groups:
  - Total links
  - Show-up rate
  - Groups you're in
- Your "rep": title based on stats (e.g. "the anchor", "the planner", "the surprise guest")
- Settings: notifications, location privacy, connected accounts
- **New idea:** "your most frequent crew" — shows which group you link up with most

---

## 11. Notifications (system-level)

- Survey request: "arh wants to plan something — what are you feeling?"
- Nudge: "still waiting on you to vote 👀"
- Plan locked: "it's official. [plan] is happening. you in?"
- Pre-event hype: "tomorrow's the day 🔥"
- Post-event: "how'd it go?"
- Flake alert: "3 people dropped out. plan might be dead 💀"

---

## Tech Stack Suggestions (iOS)

- **Language:** Swift / SwiftUI
- **Backend:** Supabase (auth via phone/OTP, realtime for live voting, DB for groups/plans)
- **AI:** LLM API (aggregation + conflict resolution + spot suggestions)
- **Maps/Places:** MapKit + Google Places API
- **Payments (Big Trip):** Stripe
- **Push:** APNs via Supabase Edge Functions or a simple backend

---

## Open Questions to Decide

1. MVP scope — what's the first version? (Suggestion: screens 1–7 only, no Big Trip mode)
2. Is the poll anonymous or named? (Currently leaning named — accountability is the brand)
3. Do we build the group chat in-app or just deeplink to existing gc?
4. Payments — in-app from day 1 or later?
5. AI suggestions — fully automated or does the group creator curate before the poll?

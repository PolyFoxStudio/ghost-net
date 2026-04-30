# Beat 11 Visual Flow Diagram

## Complete Narrative Flow

```
╔════════════════════════════════════════════════════════════════════════╗
║                         BEAT 04 COMPLETES                              ║
║                    (Player chooses A, B, or C)                         ║
╚════════════════════════════════════════════════════════════════════════╝
                                    │
                                    ▼
                        ┌───────────────────────┐
                        │  Start 45s Timer      │
                        │  Check: beat_11_sent? │
                        └───────────┬───────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
                   Yes                             No
        (Flag already set)              (Not yet triggered)
                    │                               │
                    ▼                               ▼
            ╔═══════════════╗           ┌─────────────────────┐
            ║   CANCELLED   ║           │ Timer Running...    │
            ║  (No Beat 11) ║           │ 0s → 45s           │
            ╚═══════════════╝           └──────────┬──────────┘
                                                   │
                                    ┌──────────────┴──────────────┐
                                    │                             │
                                    │    Player Messages Marcus?  │
                                    │    (At any point 0-45s)     │
                                    │                             │
                                    └──────────────┬──────────────┘
                                                   │
                                    ┌──────────────┴──────────────┐
                                    │                             │
                                   Yes                           No
                        (Any Marcus interaction)      (No interaction)
                                    │                             │
                                    ▼                             ▼
                        ╔═══════════════════╗         ┌─────────────────┐
                        ║  SET FLAG         ║         │ Timer Expires   │
                        ║  beat_11_sent=true║         │ at 45s          │
                        ║  CANCELLED        ║         └────────┬────────┘
                        ╚═══════════════════╝                  │
                                                               ▼
                                                    ┌──────────────────┐
                                                    │ Check flag again │
                                                    │ beat_11_sent?    │
                                                    └────────┬─────────┘
                                                             │
                                                  ┌──────────┴──────────┐
                                                  │                     │
                                                 Yes                   No
                                    (Cancelled during wait)   (Still clear)
                                                  │                     │
                                                  ▼                     ▼
                                        ╔═══════════════╗   ┌──────────────────┐
                                        ║   CANCELLED   ║   │ SET FLAG         │
                                        ║               ║   │ beat_11_sent=true│
                                        ╚═══════════════╝   │ FIRE BEAT 11     │
                                                            └────────┬─────────┘
                                                                     │
                                                                     ▼
╔════════════════════════════════════════════════════════════════════════════════════════╗
║                              BEAT 11 MESSAGES (MARCUS)                                 ║
║                                                                                        ║
║  [0.0s]  "i'm sorry to message again"                                                 ║
║  [2.0s]  "i know you said you'd be in touch"                                          ║
║  [1.5s]  "it's been four days since we spoke"                                         ║
║  [2.0s]  "i'm not — i'm fine. i'm okay."                                              ║
║  [2.5s]  "i just. is there anything?"                                                 ║
║  [1.0s]  "anything at all?"                                                           ║
║  [1.5s]  "even if it's small."                                                        ║
║  [3.0s]  "i keep going back and forth between thinking she's okay and thinking        ║
║           she's not"                                                                   ║
║  [2.0s]  "and the not knowing is the worst part"                                      ║
║  [2.5s]  "i just need to know you're still looking"                                   ║
║                                                                                        ║
║  Total: 10 messages over ~19.5 seconds                                                ║
╚════════════════════════════════════════════════════════════════════════════════════════╝
                                                │
                                                ▼
                                ┌───────────────────────────┐
                                │   PLAYER CHOICE PROMPT    │
                                │   (3 options appear)      │
                                └────────────┬──────────────┘
                                             │
                        ┌────────────────────┼────────────────────┐
                        │                    │                    │
                        ▼                    ▼                    ▼
            ╔═══════════════════╗ ╔═══════════════════╗ ╔═══════════════════╗
            ║   OPTION A        ║ ║   OPTION B        ║ ║   OPTION C        ║
            ║   (+1 score)      ║ ║   (0 score)       ║ ║   (-1 score)      ║
            ╚═══════════════════╝ ╚═══════════════════╝ ╚═══════════════════╝
            "I'm still looking.   "There's something    "I'll be in touch
            I've found a lot.     here. I'm not         when there's
            I just need a         ready to tell you     something worth
            little more time."    what yet. But         saying."
                                  there's something."
                        │                    │                    │
                        ▼                    ▼                    ▼
            ┌───────────────────┐ ┌──────────────────┐ ┌──────────────────┐
            │ marcus_emotional  │ │ marcus_emotional │ │ marcus_emotional │
            │ _state += 1       │ │ _state += 0      │ │ _state -= 1      │
            └───────┬───────────┘ └────────┬─────────┘ └────────┬─────────┘
                    │                      │                     │
                    ▼                      ▼                     ▼
╔═══════════════════════════╗ ╔══════════════════════╗ ╔═══════════════════════╗
║  RESPONSE A (18 messages) ║ ║ RESPONSE B (5 msg)   ║ ║ RESPONSE C (4 msg)    ║
╚═══════════════════════════╝ ╚══════════════════════╝ ╚═══════════════════════╝
            │                            │                        │
            ▼                            ▼                        ▼
┌───────────────────────┐    ┌─────────────────────┐  ┌────────────────────┐
│ "okay"                │    │ "okay"              │  │ "right"            │
│ "thank you"           │    │ "okay i trust you"  │  │ "yeah"             │
│ "that's enough"       │    │ "just"              │  │ "of course"        │
│ "that's enough for    │    │ "when you're ready" │  │ [3.0s pause]       │
│  now"                 │    │ "i'm here"          │  │ "sorry for         │
│ [1.5s pause]          │    └─────────────────────┘  │  messaging"        │
│ [player_name]         │                             └────────────────────┘
│ "she used to leave    │
│  little notes around  │
│  the flat"            │
│ "not important ones.  │
│  just like reminders. │
│  shopping lists."     │
│ "there's one on the   │
│  fridge right now"    │
│ "it starts as a       │
│  grocery list"        │
│ "milk, coffee, the    │
│  good bread from the  │
│  turkish place"       │
│ "and then halfway     │
│  down she's crossed   │
│  something out"       │
│ "it looks like a      │
│  name"                │
│ "i can't read what it │
│  says. she crossed    │
│  it out hard."        │
│ "i keep looking at it"│
│ "i haven't taken any  │
│  of them down"        │
│ "is that weird"       │
│ "you don't have to    │
│  answer that"         │
│ "fuck i'm sorry. that │
│  wasn't a useful      │
│  thing to tell you."  │
└───────────────────────┘

                        ALL PATHS CONVERGE
                                │
                                ▼
                    ┌───────────────────────┐
                    │   BEAT 11 COMPLETE    │
                    │   Flag: beat_11_sent  │
                    │   Will never fire     │
                    │   again this session  │
                    └───────────────────────┘
```

---

## Timing Breakdown

### Total Possible Durations

**Minimum Duration (Option C chosen):**
- Initial messages: ~19.5s
- Player choice time: ~variable
- Response C: ~7.0s (4 messages + pauses)
- **Total: ~26.5+ seconds**

**Maximum Duration (Option A chosen):**
- Initial messages: ~19.5s
- Player choice time: ~variable
- Response A: ~36+ seconds (18 messages with default delays)
- **Total: ~55.5+ seconds**

**Medium Duration (Option B chosen):**
- Initial messages: ~19.5s
- Player choice time: ~variable
- Response B: ~10s (5 messages)
- **Total: ~29.5+ seconds**

---

## State Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                         INITIAL STATE                            │
│  Beat 04 Complete | beat_11_sent = false | Timer = not started  │
└─────────────────────────────┬────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                        TIMER ACTIVE                              │
│  Countdown: 45s → 0s | Monitoring Marcus interactions           │
└─────────────────────────────┬────────────────────────────────────┘
                              │
                ┌─────────────┴─────────────┐
                │                           │
                ▼                           ▼
┌───────────────────────────┐  ┌────────────────────────────────┐
│  CANCELLED STATE          │  │  TRIGGERED STATE               │
│  beat_11_sent = true      │  │  beat_11_sent = true           │
│  No messages sent         │  │  Messages queued               │
│  (via Marcus interaction) │  │  (timer expired)               │
└───────────────────────────┘  └──────────────┬─────────────────┘
        │                                     │
        │                                     ▼
        │                      ┌──────────────────────────────┐
        │                      │  MESSAGES DELIVERING         │
        │                      │  10 messages over ~19.5s     │
        │                      └──────────────┬───────────────┘
        │                                     │
        │                                     ▼
        │                      ┌──────────────────────────────┐
        │                      │  AWAITING PLAYER CHOICE      │
        │                      │  3 options displayed         │
        │                      └──────────────┬───────────────┘
        │                                     │
        │                                     ▼
        │                      ┌──────────────────────────────┐
        │                      │  RESPONSE DELIVERING         │
        │                      │  4-18 messages (based on     │
        │                      │  player choice)              │
        │                      └──────────────┬───────────────┘
        │                                     │
        └─────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                        COMPLETE STATE                            │
│  beat_11_sent = true | Cannot re-trigger | Session flag set     │
└──────────────────────────────────────────────────────────────────┘
```

---

## Interaction Timeline

```
Second 0    ▼ Beat 04 completes (A, B, or C)
            │ Timer starts
            │
Second 10   │ ... player doing other things ...
            │
Second 20   │ ... still waiting ...
            │
Second 30   │ ... player might message Marcus here → CANCELLED
            │
Second 40   │ ... last chance to cancel ...
            │
Second 45   ▼ Timer expires
            ▼ Flag check: beat_11_sent?
            ▼ If false: Set flag, fire beat_11
            │
Second 45   ▼ "i'm sorry to message again"
            │
Second 47   ▼ "i know you said you'd be in touch"
            │
Second 48.5 ▼ "it's been four days since we spoke"
            │
Second 50.5 ▼ "i'm not — i'm fine. i'm okay."
            │
Second 53   ▼ "i just. is there anything?"
            │
Second 54   ▼ "anything at all?"
            │
Second 55.5 ▼ "even if it's small."
            │
Second 58.5 ▼ "i keep going back and forth..."
            │
Second 60.5 ▼ "and the not knowing is the worst part"
            │
Second 63   ▼ "i just need to know you're still looking"
            │
Second 64.5 ▼ Player choices appear
            │
            ... player takes time to read and choose ...
            │
            ▼ Player selects option A, B, or C
            ▼ Marcus emotional state adjusts
            ▼ Response messages deliver (4-18 depending on choice)
            │
            ▼ BEAT 11 COMPLETE
```

---

## Decision Tree

```
                            Player at 44s into timer
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                                   │
            Has player messaged               Has player NOT messaged
            Marcus yet?                       Marcus yet?
                    │                                   │
                   Yes                                 No
                    │                                   │
                    ▼                                   ▼
            beat_11_sent = true              Timer expires at 45s
            Beat 11 cancelled                        ▼
            (Silent, no feedback)           beat_11_sent = true
                                             Beat 11 fires
                                                    ▼
                                            10 Messages deliver
                                                    ▼
                                            Player sees choices
                                                    │
                                ┌───────────────────┼───────────────────┐
                                │                   │                   │
                            Choose A            Choose B            Choose C
                                │                   │                   │
                                ▼                   ▼                   ▼
                        marcus_state += 1    marcus_state += 0   marcus_state -= 1
                                │                   │                   │
                                ▼                   ▼                   ▼
                        18 messages          5 messages          4 messages
                        Personal detail      Trust/patience      Withdrawal
                        Uses player name     Brief, supportive   Apology
                        Grocery list story   "i'm here"          "sorry for messaging"
```

---

## Message Content Visual

### Initial 10 Messages (All Players See These)

```
┌─────────────────────────────────────────────────────────┐
│ marcus                                                  │
│ i'm sorry to message again                             │
└─────────────────────────────────────────────────────────┘
                    ↓ 2.0s
┌─────────────────────────────────────────────────────────┐
│ marcus                                                  │
│ i know you said you'd be in touch                      │
└─────────────────────────────────────────────────────────┘
                    ↓ 1.5s
┌─────────────────────────────────────────────────────────┐
│ marcus                                                  │
│ it's been four days since we spoke                     │
└─────────────────────────────────────────────────────────┘
                    ↓ 2.0s
┌─────────────────────────────────────────────────────────┐
│ marcus                                                  │
│ i'm not — i'm fine. i'm okay.                          │
└─────────────────────────────────────────────────────────┘
                    ↓ 2.5s
┌─────────────────────────────────────────────────────────┐
│ marcus                                                  │
│ i just. is there anything?                             │
└─────────────────────────────────────────────────────────┘
                    ↓ 1.0s
┌─────────────────────────────────────────────────────────┐
│ marcus                                                  │
│ anything at all?                                       │
└─────────────────────────────────────────────────────────┘
                    ↓ 1.5s
┌─────────────────────────────────────────────────────────┐
│ marcus                                                  │
│ even if it's small.                                    │
└─────────────────────────────────────────────────────────┘
                    ↓ 3.0s
┌─────────────────────────────────────────────────────────┐
│ marcus                                                  │
│ i keep going back and forth between thinking she's    │
│ okay and thinking she's not                            │
└─────────────────────────────────────────────────────────┘
                    ↓ 2.0s
┌─────────────────────────────────────────────────────────┐
│ marcus                                                  │
│ and the not knowing is the worst part                  │
└─────────────────────────────────────────────────────────┘
                    ↓ 2.5s
┌─────────────────────────────────────────────────────────┐
│ marcus                                                  │
│ i just need to know you're still looking               │
└─────────────────────────────────────────────────────────┘
                    ↓
        ┌─────────────────────────────┐
        │   PLAYER CHOICE APPEARS     │
        └─────────────────────────────┘
```

---

## Emotional Arc

```
Marcus's Emotional State During Beat 11:

High ┤
     │                                        ┌──── Option A Response
     │                                   ┌────┤     (Relief, opens up)
     │                                   │    └────
     │                              ┌────┤
     │                              │    └──── Option B Response
     │                         ┌────┤         (Stable, trusting)
     │                         │    │
     │                    ┌────┤    └──────── Option C Response
Med  ┤               ┌────┘    │             (Brief, withdrawn)
     │          ┌────┘         │
     │     ┌────┘              │
     │ ┌───┘                   │
     ├─┘   Anxiety Rising      └─ Player Choice Impact
Low  ┤    (10 messages)           (Score adjustment)
     │
     └────┬────────┬────────┬────────┬────────┬────────┬
       Start   Msg 3   Msg 6   Msg 9  Choice  Response
      Beat11                            Made   Complete
```

---

## Flag State Machine

```
┌─────────────┐
│   START     │
│ beat_11_sent│
│   = false   │
└──────┬──────┘
       │
       ▼
┌──────────────────────────────────┐
│  ANY of these events occurs:     │
│  • Timer expires (45s)           │
│  • Player messages Marcus        │
└──────┬───────────────────────────┘
       │
       ▼
┌─────────────┐
│  SET FLAG   │
│ beat_11_sent│
│   = true    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────┐
│  PERMANENT STATE                │
│  • Cannot be unset              │
│  • Persists across save/load    │
│  • Checked on timer start       │
│  • Checked before firing        │
│  • Prevents all future triggers │
└─────────────────────────────────┘
```

---

This visual flow document provides a complete graphical representation of Beat 11's behavior, timing, and state management.

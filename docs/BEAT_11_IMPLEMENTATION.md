# Beat 11 — Marcus Checks In

## Implementation Summary

Beat 11 is an automatic idle check that fires 45 seconds after Beat 04 completes, simulating "24 hours of in-game silence" where Marcus reaches out to check on the investigation progress.

---

## 🎯 Overview

**Trigger:** 45 seconds after Beat 04 (any variant: A, B, or C) completes  
**Thread:** Marcus  
**Type:** Idle check with player choice  
**Flag:** `beat_11_sent`  
**Cancellable:** Yes - cancelled if player messages Marcus before 45s expires

---

## 📋 Implementation Details

### 1. Timer Trigger (Line 175-177)

After Beat 04 responses (A, B, or C) complete, the timer starts:

```gdscript
elif beat_id in ["beat_04_A", "beat_04_B", "beat_04_C"]:
    # After Beat 04 completes, start timer for Beat 11 (Marcus idle check)
    _start_beat11_timer()
```

### 2. Thread Routing (Line 180)

Beat 11 is routed to the Marcus thread:

```gdscript
if beat_id.begins_with("beat_04") or beat_id.begins_with("beat_11") or beat_id.begins_with("beat_13") or beat_id.begins_with("beat_15"): return "marcus"
```

### 3. Messages (Lines 357-405)

**Initial Beat 11 Messages (10 messages over ~19.5 seconds):**
- "i'm sorry to message again" (0.0s)
- "i know you said you'd be in touch" (2.0s)
- "it's been four days since we spoke" (1.5s)
- "i'm not — i'm fine. i'm okay." (2.0s)
- "i just. is there anything?" (2.5s)
- "anything at all?" (1.0s)
- "even if it's small." (1.5s)
- "i keep going back and forth between thinking she's okay and thinking she's not" (3.0s)
- "and the not knowing is the worst part" (2.0s)
- "i just need to know you're still looking" (2.5s)

**Option A Response (18 messages):**
Marcus finds reassurance and opens up about Nadia's notes around the flat.
- Uses `GameState.player_name` for personalization
- Describes grocery list on fridge with crossed-out name
- Shows vulnerability and trust building
- Score: +1 (Calm recovery)

**Option B Response (5 messages):**
Marcus expresses trust and patience.
- Short, simple acknowledgment
- Shows restraint and understanding
- Score: 0 (Neutral)

**Option C Response (4 messages):**
Marcus accepts but shows signs of emotional distance.
- Apologizes for reaching out
- Withdrawal behavior
- Score: -1 (Spiral risk)

### 4. Player Choices (Lines 634-639)

Three response options after Marcus's 10 messages:

| Choice | Text | Next Beat | Score | Effect |
|--------|------|-----------|-------|--------|
| **A** | "I'm still looking. I've found a lot. I just need a little more time." | beat_11_A | +1 | Calm recovery |
| **B** | "There's something here. I'm not ready to tell you what yet. But there's something." | beat_11_B | 0 | Neutral |
| **C** | "I'll be in touch when there's something worth saying." | beat_11_C | -1 | Spiral risk |

### 5. Cancellation Logic (Lines 691-693)

If player sends ANY message to Marcus before the 45s timer expires, Beat 11 is cancelled:

```gdscript
# Reset Beat 11 idle timer if player interacts with Marcus thread
if choice["target"] == "marcus" and not GameState.get_flag("beat_11_sent"):
    GameState.set_flag("beat_11_sent", true)
```

### 6. Timer Functions (Lines 828-845)

**Start Timer:**
```gdscript
func _start_beat11_timer() -> void:
    if GameState.get_flag("beat_11_sent"):
        return
    
    await get_tree().create_timer(45.0).timeout
    
    if GameState.get_flag("beat_11_sent"):
        return  # player already interacted — cancel
    
    _fire_beat11()
```

**Fire Beat:**
```gdscript
func _fire_beat11() -> void:
    GameState.set_flag("beat_11_sent", true)
    
    # Queue to Marcus thread with player choice at the end
    trigger_beat("beat_11")
```

---

## 🔄 Flow Diagram

```
Beat 04 Response (A, B, or C) Completes
        ↓
    Start 45s Timer
        ↓
    ┌───────────────────────────┐
    │                           │
    │  Player messages Marcus?  │
    │                           │
    └───────────┬───────────────┘
                │
        ┌───────┴───────┐
        │               │
       YES             NO
        │               │
        ↓               ↓
    Cancel Timer    Timer Expires
    Set Flag        Set Flag
    (No Beat 11)    Trigger Beat 11
                         ↓
                    Marcus: 10 Messages
                         ↓
                    Player Choice A/B/C
                         ↓
                    Marcus Response
```

---

## ✅ Key Features

### Emotional Design
- **Vulnerable Opening:** Marcus apologizes for reaching out, showing anxiety
- **Desperation:** "anything at all? even if it's small."
- **Emotional Turmoil:** The back-and-forth between hope and despair
- **Time Dilation:** "it's been four days" (in-game vs real-time)

### Option A Deep Dive
The most detailed response where Marcus:
1. Finds enough reassurance to breathe
2. Uses player's name (personalization moment)
3. Shares intimate detail about Nadia's notes
4. Shows he hasn't been able to move on (notes still on fridge)
5. Questions if his behavior is normal
6. Catches himself and apologizes for oversharing

This response is designed to show trust building and Marcus letting his guard down.

### Cancellation Behavior
- **Silent cancellation** - no notification to player
- **Any Marcus interaction** cancels it, not just specific beats
- **Flag persists** - once set, Beat 11 can never fire again
- **One-time only** - respects player agency

---

## 🧪 Testing Checklist

### Basic Functionality
- [ ] Beat 11 fires 45s after beat_04_A completes
- [ ] Beat 11 fires 45s after beat_04_B completes
- [ ] Beat 11 fires 45s after beat_04_C completes
- [ ] All 10 Marcus messages appear with correct delays
- [ ] Player choices appear after final message
- [ ] Each choice leads to correct response variant

### Cancellation Testing
- [ ] Messaging Marcus at 30s cancels Beat 11
- [ ] Messaging Marcus at 44s cancels Beat 11
- [ ] Messaging Cipher does NOT cancel Beat 11
- [ ] Flag prevents Beat 11 from firing after cancellation
- [ ] No error or notification on cancellation

### Score Impact
- [ ] Option A increases marcus_emotional_state by +1
- [ ] Option B leaves marcus_emotional_state unchanged
- [ ] Option C decreases marcus_emotional_state by -1

### Content Verification
- [ ] Player name appears correctly in beat_11_A
- [ ] All message timings feel natural
- [ ] No missing or duplicate messages
- [ ] Thread routing to Marcus works correctly

### Edge Cases
- [ ] Beat 11 doesn't fire if flag already set
- [ ] Beat 11 works correctly if player never interacts
- [ ] Save/load preserves beat_11_sent flag
- [ ] Multiple Beat 04 completions don't create multiple timers

---

## 🔗 Integration Points

**Requires:**
- `GameState.get_flag()` / `set_flag()` - Flag management
- `GameState.adjust_marcus_state()` - Score adjustment
- `GameState.player_name` - Player name substitution
- `trigger_beat()` - Beat triggering system
- `_process_message_queue()` - Message delivery

**Modifies:**
- Marcus message thread
- GameState flags (`beat_11_sent`)
- Marcus emotional state score

**Depends On:**
- Beat 04 completion (any variant)

**No Dependencies On:**
- Cipher relationship score
- Game progression state
- Other beat completions

---

## 📝 Notes

### Design Intent
Beat 11 simulates the realistic behavior of someone waiting for news about a missing loved one. The 45-second timer represents "days" of in-game silence, and Marcus's increasing anxiety is natural. The player's response options allow them to either reassure, be mysterious, or create distance.

### Option A Special Content
The grocery list detail in Option A is a small, intimate moment that:
- Shows Marcus hasn't moved on
- Reveals how he's coping (or not coping)
- Provides potential investigative detail (crossed-out name)
- Builds emotional connection with player
- Makes the case feel more real and personal

### Why Cancellable?
Unlike Beat 10c (Cipher idle check), Beat 11 is designed to respect player agency. If the player is already engaging with Marcus, they don't need him reaching out. This prevents the feeling of "spam" and makes Marcus's check-in feel more meaningful when it does fire.

---

## 🚀 Implementation Status

✅ Timer trigger after Beat 04 responses  
✅ Thread routing to Marcus  
✅ 10 initial messages with delays  
✅ 3 player choice options  
✅ 3 Marcus response variants  
✅ Cancellation logic in _resolve_player_choice  
✅ Timer and fire functions  
✅ Flag management  
✅ Player name substitution  
✅ Score adjustments  

**Status:** Complete and ready for testing

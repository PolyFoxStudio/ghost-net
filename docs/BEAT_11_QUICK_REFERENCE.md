# Beat 11 Quick Reference

## At a Glance

| Beat | Trigger | Timing | Condition | Cancellable | Messages |
|------|---------|--------|-----------|-------------|----------|
| **11** | After Beat 04 | 45s | Always | Yes (any Marcus interaction) | 10 + choice + response |

---

## Core Details

**What:** Marcus checks in after days of silence, anxious about progress

**When:** 45 seconds after Beat 04 (A, B, or C) completes

**Thread:** Marcus

**Flag:** `beat_11_sent`

**Cancellation:** Any player message to Marcus thread before 45s expires

---

## Message Flow

### Initial Messages (10 total, ~19.5s)
```
"i'm sorry to message again"
"i know you said you'd be in touch"
"it's been four days since we spoke"
"i'm not — i'm fine. i'm okay."
"i just. is there anything?"
"anything at all?"
"even if it's small."
"i keep going back and forth between thinking she's okay and thinking she's not"
"and the not knowing is the worst part"
"i just need to know you're still looking"
```

### Player Choices

**Option A (+1):** "I'm still looking. I've found a lot. I just need a little more time."
- Marcus opens up about Nadia's notes
- 18 messages including personal details
- Uses player name
- Calm recovery

**Option B (0):** "There's something here. I'm not ready to tell you what yet. But there's something."
- Short, trusting response
- 5 messages
- Neutral stance

**Option C (-1):** "I'll be in touch when there's something worth saying."
- Marcus withdraws
- 4 messages including apology
- Spiral risk

---

## Code Locations

| Component | Lines | Description |
|-----------|-------|-------------|
| Timer Trigger | 175-177 | Starts after beat_04 responses |
| Thread Routing | 180 | Routes beat_11 to Marcus |
| Initial Messages | 357-369 | 10 Marcus check-in messages |
| Response A | 370-390 | 18 messages, personal detail |
| Response B | 391-398 | 5 messages, trust |
| Response C | 399-405 | 4 messages, withdrawal |
| Player Choices | 634-639 | 3 options with scores |
| Cancellation | 691-693 | Marcus interaction check |
| Timer Function | 828-845 | Start and fire logic |

---

## Flow Chart

```
Beat 04 Completes
      ↓
  Start Timer (45s)
      ↓
  Check flag: beat_11_sent?
      ↓
     Yes → Cancel
      ↓
     No → Continue
      ↓
  Player messages Marcus?
      ↓
   Yes → Set flag → Cancel
      ↓
   No → Timer expires
      ↓
  Set flag: beat_11_sent = true
      ↓
  Trigger beat_11
      ↓
  10 Messages delivered
      ↓
  Show 3 player choices
      ↓
  Player selects option
      ↓
  Adjust marcus_emotional_state
      ↓
  Deliver Marcus response
```

---

## Testing Quick Checks

### Must Work
- ✓ Fires 45s after beat_04_A/B/C
- ✓ All 10 messages appear in order
- ✓ Choices appear after messages
- ✓ Each choice → correct response
- ✓ Score adjustments (+1, 0, -1)
- ✓ Player name in Option A response

### Must Cancel
- ✓ Any Marcus message before 45s
- ✓ Flag prevents re-firing
- ✓ No error on cancellation

### Must NOT Cancel
- ✓ Cipher messages don't cancel
- ✓ Other thread interactions don't cancel

---

## Common Issues

**Issue:** Beat 11 fires twice
- **Check:** Flag logic in _start_beat11_timer()
- **Fix:** Ensure beat_11_sent checked before firing

**Issue:** Not cancelling on Marcus interaction
- **Check:** Lines 691-693 in _resolve_player_choice
- **Fix:** Verify target == "marcus" condition

**Issue:** Wrong response variant
- **Check:** beat_11_A/B/C in _get_beat_messages
- **Fix:** Match next beat_id to correct variant

**Issue:** Player name not showing
- **Check:** Line 376 uses GameState.player_name
- **Fix:** Ensure GameState.player_name is set

---

## Key Differences from Beat 10c

| Feature | Beat 10c (Cipher) | Beat 11 (Marcus) |
|---------|-------------------|------------------|
| **Timing** | 45s after Beat 10 | 45s after Beat 04 |
| **Thread** | Cipher | Marcus |
| **Condition** | cipher_score >= -2 | Always fires |
| **Cancellation** | Cipher interaction | Marcus interaction |
| **Player Choice** | None | 3 options |
| **Messages** | 9 (no response) | 10 + response variants |
| **Purpose** | Check player is there | Anxiety about progress |

---

## Integration Notes

**Triggers After:**
- beat_04_A, beat_04_B, or beat_04_C

**Uses:**
- `GameState.get_flag("beat_11_sent")`
- `GameState.set_flag("beat_11_sent", true)`
- `GameState.player_name`
- `GameState.adjust_marcus_state(score)`

**Affects:**
- Marcus thread message history
- marcus_emotional_state score
- Narrative pacing

**No Impact On:**
- Cipher relationship
- Investigation progress
- Other beat timers
- Game systems

---

## Narrative Purpose

Beat 11 serves to:
1. **Show time passing** - "four days" creates in-game temporal depth
2. **Build Marcus character** - Vulnerable, anxious, trying to stay composed
3. **Player agency** - Three distinct emotional responses
4. **Trust building** - Option A reveals intimate personal details
5. **Consequence setup** - Low responses push Marcus toward spiral

The grocery list detail in Option A is particularly important:
- **Realism** - Small, specific, mundane detail makes grief tangible
- **Mystery hook** - Crossed-out name could be investigative lead
- **Emotional weight** - Marcus hasn't moved anything, frozen in time
- **Vulnerability** - Questions if his behavior is "weird"

---

## Performance Notes

- Timer is lightweight (single await)
- Flag check prevents unnecessary work
- Messages use standard delivery system
- No special rendering or systems involved
- Cancellation is instant (no cleanup needed)

---

## Save/Load Considerations

**Must Persist:**
- `beat_11_sent` flag

**Don't Persist:**
- Active timer state (resets on load)
- Message queue (cleared on load)

**On Save:**
- Flag is automatically saved via GameState

**On Load:**
- Timer does NOT restart
- If Beat 04 completed before save, Beat 11 won't fire after load
- This is intentional - prevents duplicate/late firing

---

## Future Expansion Hooks

Potential future uses:
- **Crossed-out name** could be investigative clue in later beats
- **Emotional state check** could gate future Marcus behaviors
- **beat_11_sent** could be referenced in ending variations
- **Response choice** could affect Marcus's final reaction to news

---

## Final Notes

Beat 11 is designed to feel **natural and unobtrusive** while adding emotional depth. Unlike automatic story beats, this idle check:
- Only fires if player is genuinely idle on Marcus thread
- Respects player's active engagement
- Provides meaningful choice without pressure
- Builds character through vulnerability

The 45-second timing is calibrated to feel like "I should probably check in" rather than "I'm ignoring you" from Marcus's perspective.

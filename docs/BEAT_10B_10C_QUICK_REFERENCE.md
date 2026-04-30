# Beat 10b & 10c Quick Reference

## At a Glance

| Beat | Trigger | Timing | Condition | Cancellable | Files/Messages |
|------|---------|--------|-----------|-------------|----------------|
| **10b** | After Beat 10 | 30s | cipher_score >= 5 | No | 2 files silently dropped |
| **10c** | After Beat 10 | 45s | cipher_score >= -2 | Yes (if player interacts) | 9 Cipher messages |

---

## Beat 10b — Silent File Drop

**What:** Cipher leaves files on local machine before going offline

**Where:**
- `/home/ghost/note_for_ghost.txt` - Personal note from Cipher
- `/tmp/kc_trace_partial.log` - Incomplete Kane trace data

**Gate:** `is_convergence_mid()` → cipher_score >= 5 AND marcus_state >= 0

**Flag:** `beat_10b_dropped`

**Key Code Locations:**
- Timer start: `phantom_link_window.gd` line ~173
- File drop: `_drop_beat10b_file()` line ~666
- Content: `_get_beat10b_note_content()` line ~699
- Helpers: `local_machine_setup.gd` lines ~94-121

---

## Beat 10c — Cipher Idle Check

**What:** Cipher checks if player is still there after going quiet

**Messages:** 9 messages over ~17 seconds total
- "hey"
- "just checking you're still there"
- "you go quiet when things get heavy"
- "i've noticed that"
- "it's fine. i know it's how you work."
- "i just"
- "you don't have to do that here"
- "i'm not going anywhere"
- "okay. carry on. ignore me."

**Gate:** `get_cipher_threshold() != "low"` → cipher_score >= -2

**Flag:** `beat_10c_sent`

**Cancellation:** Player sending ANY message to Cipher before 45s expires

**Key Code Locations:**
- Timer start: `phantom_link_window.gd` line ~174
- Fire check: `_fire_beat10c()` line ~748
- Cancellation: `_resolve_player_choice()` line ~630

---

## Flow Diagram

```
Beat 10 Completes (Cipher discovers VaultPay)
        |
        ├─> Beat 10b Timer (30s) ──> [if cipher >= 5] ──> Drop Files Silently
        |                                    └─> [else] ──> Nothing
        |
        └─> Beat 10c Timer (45s) ──> [if cipher >= -2 AND not interacted] ──> Send Messages
                                               └─> [else] ──> Cancel
```

---

## Testing Checklist

### Beat 10b
- [ ] Files appear after 30s when cipher_score >= 5
- [ ] Files do NOT appear when cipher_score < 5
- [ ] Files contain correct content (note + log)
- [ ] Files appear in correct locations (/home/ghost/, /tmp/)
- [ ] No UI notification or PhantomLink message
- [ ] Flag prevents duplicate drops

### Beat 10c
- [ ] Messages appear after 45s when cipher_score >= -2
- [ ] Messages do NOT appear when cipher_score < -2
- [ ] Messages are cancelled if player responds to Cipher first
- [ ] 9 messages with correct timing delays
- [ ] No player response prompted
- [ ] Flag prevents duplicate sends

---

## Common Issues & Solutions

**Issue:** Files not appearing
- Check cipher_relationship_score is >= 5
- Check beat_10b_dropped flag hasn't already been set
- Verify NetworkManager has local machine (127.0.0.1)

**Issue:** Idle check firing when it shouldn't
- Check cipher_relationship_score is >= -2
- Verify beat_10c_sent flag logic in _resolve_player_choice

**Issue:** Idle check not cancelling on interaction
- Verify flag is set in _resolve_player_choice BEFORE player messages Cipher
- Check flag is checked in both timer and fire functions

---

## Integration Points

**Requires:**
- GameState.is_convergence_mid() - checks cipher >= 5 and marcus >= 0
- GameState.get_cipher_threshold() - returns "low", "mid", or "high"
- GameState.get_flag() / set_flag() - flag persistence
- NetworkManager.get_machine() - access to local filesystem
- LocalMachineSetup.find_node_in_fs() - filesystem traversal
- LocalMachineSetup.find_or_create_dir() - directory creation

**Modifies:**
- Local machine filesystem (127.0.0.1)
- Cipher message thread
- GameState flags (beat_10b_dropped, beat_10c_sent)

**No modifications to:**
- Beat 10 itself (just hooks into completion)
- Other beats or dialogue flows
- Player choice options
- Cipher relationship scoring

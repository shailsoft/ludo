# Ludo Arena rules

## Canonical board

The shared track has indices `0..51`, clockwise. Color start offsets are Red `0`, Green `13`, Yellow `26`, and Blue `39`. A token's relative progress `0..51` maps to `(startOffset + progress) mod 52`. After relative progress 51, it enters only its own six-cell home lane at progress `52..57`; progress 57 is the finished home position.

Default safe absolute squares are all starts plus four marked stars: `{0, 8, 13, 21, 26, 34, 39, 47}`. Opponents on these squares are never captured. Same-color tokens may share any permitted square; stacking does not block traversal in the MVP.

## Classic profile (default)

- Four tokens per player; all four must finish.
- Yard entry requires a 6 and places the token on relative progress 0.
- A track/home token advances exactly the dice value. Progress beyond 57 is illegal.
- Landing on an opponent on a non-safe outer square returns every opponent token on that square to its yard. Safe squares cannot capture.
- A 6 grants another roll after its move (or after no move), unless it is the third uninterrupted consecutive 6.
- The third consecutive 6 is not applied; it is forfeited and the turn ends. The counter resets whenever the turn changes.
- Capture and reaching home do not grant extra turns by default.
- If no legal move exists, the turn ends unless a non-penalized 6 grants the configured extra roll.
- Players may act only during their own active turn. No second roll is accepted while a move is pending.

## Quick profile

Quick uses exactly the same board and movement rules with two active tokens per player. A player wins when both finish. No dice bias or hidden shortcut is used.

## Supported variants

`RuleProfile` supports entry on 1 or 6, disabling the extra roll on 6, disabling the three-sixes penalty, and enabling extra turns on capture or home. Custom safe-square sets are serializable. Blockades, required-capture-to-finish, and turn timers are deferred and default off.


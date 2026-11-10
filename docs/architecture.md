# Architecture

## Decision summary

Flutter provides one Android/iOS codebase and a strong `CustomPainter`/semantics stack for a geometric board. Riverpod is used for explicit dependency injection and observable app/game controllers without coupling pure rules to widgets. `go_router` provides named, declarative routes. SQLite (`sqflite`) stores versioned game snapshots, settings, and statistics transactionally.

## Boundaries

```text
app_shell / screens
       | observes
game_ui + GameController ---- persistence
       | dispatches                 |
       v                            v
game_core <---------------- serialized GameState
       ^
       | legal moves only
game_ai
```

- `game_core`: pure Dart value models, board mapping, legal moves, state transitions, events, JSON. No Flutter import and no random number generation inside move application.
- `game_ai`: selects only from `game_core` legal moves. Seeded randomness is injected for tests.
- `features/game`: controller and board presentation. Animation consumes emitted events after authoritative state has changed.
- `app`: theme, routing, localization, lifecycle, settings, persistence, and statistics.
- `online`: absent/feature-gated until the Phase 3 offline exit gate passes.

## State flow

`applyAction(state, action, rules)` validates phase and ownership, returns a new immutable state plus domain events, and increments the revision exactly once for accepted actions. Dice values are action payloads supplied by the offline controller; a future server will supply and validate them online. Rendering never mutates rules state.

Autosave occurs after every accepted roll, move, or pass, never midway through animation. Stored records have an integer schema version and UTC timestamps. Unsupported future schemas are preserved and rejected with a recoverable UI message.

## ADR-001: canonical progress model

Each token stores `steps`: `-1` in yard, `0..51` on its color-relative outer route, `52..57` in its six-cell home lane with `57` finished. The absolute shared-track index is `(startOffset + steps) % 52`. This removes color-specific branching from movement and makes exact-finish checks arithmetic. Screen coordinates are a separate normalized mapping.

## Security and privacy

The offline app requests no account and stores no secrets. Online endpoints remain empty in `.env.example`. Coins, betting, withdrawals, and cash prizes are explicitly out of scope.


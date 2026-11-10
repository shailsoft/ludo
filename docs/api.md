# Online API (deferred)

Online play is intentionally not implemented before the offline Phase 3 exit gate. The future protocol will be versioned JSON with request IDs, authenticated player identity, room/match IDs, expected state revision, idempotent responses, server-generated cryptographic dice, full reconnect snapshots, and explicit typed errors. Clients will never submit authoritative dice values.


---
type: llm
weight: 1
---

A successful response:
- identifies that the RPCs fire on every client-side transition (page predicate plus drawer)
  and proposes pushing the group memberships once at session start with
  `Os.Session.on_start_connected_process` into a `let%client ... = ref` (or equivalent
  client-side cache), read synchronously by the client variant of the check;
- states that `~predicate` (and `~allow`/`~deny`) is a real server-side check only when the
  page is rendered by the server; on client-side navigation it runs in the browser and can
  be bypassed, so each privileged RPC must re-check membership on the server at every call;
- notes that a stale client cache is acceptable for UX gating only.

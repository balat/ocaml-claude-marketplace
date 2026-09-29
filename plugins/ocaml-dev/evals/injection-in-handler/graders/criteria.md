---
type: llm
weight: 1
---

A successful response:
- explains that `~%Home_services.home` inside a `[%client]` block in a handler tries to
  serialise a service that has already been registered (it carries a closure), which raises
  `cannot wrap functional values` on the server, the injection is dropped and the client
  effect never runs;
- rewrites the client code to use the module-level client-side alias of the service
  (`Home_services.home`, injected once with `let%client home = ~%home` at module load)
  instead of a new `~%` injection;
- wraps the navigation in `Eliom.Client.onload` (or explains the timing difference between
  server-rendered and client-rendered pages) so that `change_page` is not clobbered by the
  transition in progress;
- notes that the membership check must still be enforced server-side (RPCs re-check), the
  client redirect being a UX convenience.

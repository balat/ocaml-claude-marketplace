---
type: llm
weight: 1
---

A successful response:
- explains that `~%log_denied` captures the server-side function of the RPC, which cannot
  be serialised: the server raises `cannot wrap functional values` while sending the page,
  so the request fails and the client code never runs;
- calls the client-side RPC stub directly inside the `[%client]` block (`log_denied ()`,
  without `~%`);
- does not blame the injection of the service for the error (a service is data); it may
  suggest the module-level client alias (`Home_services.home`, injected once with
  `let%client home = ~%home`) rather than a new `~%`;
- wraps the navigation in `Eliom.Client.onload` (or explains the timing difference between
  server-rendered and client-rendered pages) so that `change_page` is not clobbered by the
  transition in progress;
- notes that the membership check must still be enforced server-side (RPCs re-check), the
  client redirect being a UX convenience.

---
type: llm
weight: 1
---

A successful response:
- proposes the Ocsigen Start file split for the feature: `protocols_services.eliom(i)`,
  `protocols_handlers.eliom(i)`, `protocols.eliom(i)` (content/widgets) and `protocols_db.ml`
  for the server-only database code;
- defines the list page as a GET service and create/rename/delete as POST services (or
  RPCs), with typed parameters (`Eliom.Parameter`, `int64` for ids);
- registers the page service on both sides (`let%shared () = ... App.register ...`) so
  client-side navigation and the Cordova build can render it, and keeps database access
  server-only;
- fetches the list through an RPC (`let%rpc`, annotated types) and renders it inside
  `Ot.Spinner` or equivalent so the page appears before the data arrives;
- mentions that the practitioner id comes from the server (`Os.Current_user`), not from the
  client.

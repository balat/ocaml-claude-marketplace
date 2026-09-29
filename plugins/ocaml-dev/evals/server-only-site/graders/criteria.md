---
type: llm
weight: 1
---

A successful response:
- defines services with `Eliom.Service.create` using `Path`, `Get`/`Post` and typed
  parameters (`Eliom.Parameter`, `suffix` or `int64`/`int` for the user id);
- builds the login form with `Form.post_form` whose field names come from the service's
  POST parameters, and registers the login as an `Action` (or equivalent) that sets
  session state;
- keeps the counter in an Eliom reference with `default_session_scope`, and logs out with
  `Eliom.State.discard`;
- handles the bad id with a fallback, `Eliom.Common.Eliom_404` or `set_exn_handler`;
- explains the build and run path: a dune executable calling `Ocsigen.Server.start` with
  `Eliom.App.run ()`, or a library loaded by `ocsigenserver -c` with a configuration file,
  or `eliom-distillery -template app.exe`;
- does not introduce `let%client` code, RPCs or client values, since no client program
  was asked for.

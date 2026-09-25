# Eliom client/server review checklist

Use when reviewing a diff that touches `.eliom` or `.eliomi` files. Each item names the
section of `SKILL.md` that explains it.

- [ ] Every top-level definition carries a section annotation; no new `[%%client.start]` blocks. (Sections)
- [ ] `open%...` limited to `Js_of_ocaml`, `Js_of_ocaml_lwt`, `Eliom.Content`, `Eliom.Content.Html`. (Sections)
- [ ] No JavaScript evaluated from strings; browser APIs go through Js_of_ocaml bindings. (Sections)
- [ ] `[%client (e : t)]` values and `let%rpc` parameters are type-annotated, RPC results too. (Types)
- [ ] RPC parameter and result types, and persistent reference types, derive `json`. (Types)
- [ ] No `int` that may exceed 2^30 reaches client code: ids, timestamps, amounts are `Int64` or strings. (Types)
- [ ] Strings from URLs, RPCs or caches are decoded to a variant once, at the boundary. (Types)
- [ ] Effects on the freshly rendered page run inside `Eliom.Client.onload`. (Client values)
- [ ] No `~%service` or `~%rpc_stub` inside a `[%client]` in a handler; the module-level client alias is used. (Injections)
- [ ] Only data is injected; values that must update on the client use `Eliom.Shared.React`. (Injections)
- [ ] Each RPC call from client code is under `Lwt.catch`, with a user-visible message and a log line. (Events)
- [ ] Repeated events use the `s`-suffixed `Lwt_js_events` loops, and the loop body catches its own exceptions. (Events)

---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

OCaml server using Lwt (cohttp-lwt-unix). Two problems in this module:

```ocaml
open Lwt.Syntax

let refresh_cache () =
  let* data = Http.fetch "https://example.org/data" in
  Cache.store data

let start () =
  ignore (refresh_cache ());
  let%lwt () = Lwt_unix.sleep 1.0 in
  Lwt_list.iter_s (fun u -> notify u) users

let handle_click () =
  Lwt.async (fun () ->
    try
      let* r = Api.call () in
      update_ui r
    with Api.Error msg -> show_error msg; Lwt.return_unit)
```

When `Http.fetch` fails, nothing is logged and the cache stays stale forever. When
`Api.call` fails the error message never appears and the click handler seems dead
afterwards. Also a colleague says the file mixes styles. Fix the module and explain each
change.

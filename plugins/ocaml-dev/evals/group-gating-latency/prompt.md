---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

Ocsigen Start app. Every page is wrapped like this:

```ocaml
let%shared page myid_o gp pp =
  My_page.connected_page
    ~predicate:(fun _ _ _ -> Groups_rpc.is_in_group "practitioner")
    (fun myid gp pp -> ...) gp pp
```

and the drawer also calls `Groups_rpc.is_in_group "admin"` to decide whether to show the
admin entry. Users complain that every navigation in the app takes 300 to 500 ms longer than
it should. Two questions: how do I get rid of that latency without duplicating the logic
everywhere, and is the `~predicate` check enough to keep non-practitioners out of the
restricted pages?

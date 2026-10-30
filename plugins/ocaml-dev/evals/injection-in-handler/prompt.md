---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

I have an Eliom app generated from the Ocsigen Start template. In `cases_handlers.eliom` I
wrote this page handler, which should log the refused access and redirect non-members to
the home page:

```ocaml
let%rpc log_denied () : unit Lwt.t = Cases_db.log_denied_access ()

let%shared cases_page myid_o () () =
  let%lwt is_member = Cases_rpc.is_practitioner () in
  if not is_member then begin
    ignore [%client (Lwt.async (fun () ->
      let%lwt () = ~%log_denied () in
      Eliom.Client.change_page ~service:~%Home_services.home () ()) : unit)];
    Lwt.return [Eliom.Content.Html.F.div []]
  end else render_cases ()
```

Non-members never reach the home page, and the server log has a line
`Failure "cannot wrap functional values"`. Explain what is wrong and rewrite the snippet so
the redirect works on both the first server-rendered request and on client-side
navigation.

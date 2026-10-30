---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

I have an Eliom app generated from the Ocsigen Start template. In `cases_handlers.eliom` I
wrote this page handler, which should redirect non-members to the home page:

```ocaml
let%shared cases_page myid_o () () =
  let%lwt is_member = Cases_rpc.is_practitioner () in
  if not is_member then begin
    ignore [%client (Lwt.async (fun () ->
      Eliom.Client.change_page ~service:~%Home_services.home () ()) : unit)];
    Lwt.return [Eliom.Content.Html.F.div []]
  end else render_cases ()
```

In the browser nothing happens for non-members: the page stays blank. The server log has a
line `Failure "cannot wrap functional values"` but the response is still 200. Explain what
is wrong and rewrite the snippet so the redirect works on both the first server-rendered
request and on client-side navigation.

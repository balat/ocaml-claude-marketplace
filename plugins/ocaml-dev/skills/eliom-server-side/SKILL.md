---
name: eliom-server-side
description: "Traditional server-side web programming with Eliom and Ocsigen Server, without a client-side program: Ocsigen Server as a library or with a configuration file, services and registration modules (Html, Action, Redirection, File, Any), typed GET and POST parameters, pathless and attached services, typed links and forms (Form.get_form, Form.post_form), sessions with Eliom references and scopes, temporary services and continuation-based programming, error handling, project setup with dune or eliom-distillery. Use when building a classic web site or HTML service in OCaml, or for the service, parameter, link, form and state fundamentals that multi-tier Eliom applications share."
---

# Server-side web programming with Eliom

Eliom is known for its client-server programming model, but it also serves traditional web
sites: pages generated on the server, links, forms and sessions, with no client-side
program. Everything here also holds in a multi-tier application, where it is the server
half; the `eliom-architecture` skill adds the client side. Handlers return Lwt promises
(see the `lwt` skill). Module names are those of Eliom 13
(`Eliom.Service`; `Eliom_service` in Eliom 12 and earlier, see
`../eliom-client-server/references/module-names.md`). Tutorial:
<https://ocsigen.org/tuto/latest/manual/basics-server>.

## Ocsigen Server

Ocsigen Server runs either as a library called from an OCaml program, or as the
`ocsigenserver` executable driven by an XML configuration file that loads the site as a
plugin. Extensions add features: `staticmod` (static files), `deflatemod` (compression),
`redirectmod`, `revproxy`, `accesscontrol`, `authbasic`, `rewritemod`. Both setups, the
directory layout, the configuration file and the timeouts are in `references/config.md`.

## Services

A service maps a request to a handler. Create it with a path and a method, then register a
handler through the registration module that matches the kind of answer:

```ocaml
let hello =
  Eliom.Service.create
    ~path:(Eliom.Service.Path ["hello"])
    ~meth:(Eliom.Service.Get Eliom.Parameter.unit)
    ()

let () =
  Eliom.Registration.Html.register ~service:hello (fun () () ->
    Lwt.return
      Eliom.Content.Html.F.(
        html (head (title (txt "Hello")) []) (body [h1 [txt "Hello"]])))
```

The handler receives the GET parameters, then the POST parameters, typed as the service
declares. Registration modules: `Html` (typed page), `Html_text` (a string), `Action`
(side effect, then the current page is shown again), `Redirection`, `File`, `String`,
`Flow` (a fragment), `Any` (the handler chooses the output), `Ocaml` (values for a client
program), `App` (pages of a client-server application). Handler types and options are in
`references/registration-modules.md`.

Kinds of services:

- Path services (`Eliom.Service.Path ["a"; "b"]`) answer at a URL.
- Pathless services (`~path:Eliom.Service.No_path`, named with `~name` or automatically)
  are identified by a parameter and answer from any page: login, logout, add to basket.
  `Eliom.Service.attach` gives a pathless service a URL.
- Attached services (`create_attached_get`, `create_attached_post`, with a `~fallback`
  path service) share the URL of the fallback and are selected by a special parameter.
- External services (`Eliom.Service.extern`) describe another site so that links and forms
  to it are typed too.
- Predefined: `Eliom.Service.static_dir ()` for static files
  (`Html.F.make_uri (Eliom.Service.static_dir ()) ["img"; "logo.png"]`) and
  `Eliom.Service.reload_action` to reload the current page.
- Options of `create`: `?max_use` and `?timeout` (temporary services), `?csrf_safe`
  (CSRF-protected pathless services), `?https`.

## Parameters

`Eliom.Parameter` describes GET and POST parameters. Eliom decodes and checks them before
calling the handler, and answers with an error (`Eliom.Common.Eliom_Wrong_parameter`)
otherwise.

```ocaml
Eliom.Parameter.(int "i" ** (string "s" ** bool "b"))   (* /path?i=42&s=x&b=on *)
Eliom.Parameter.(int "i" ** opt (string "s"))            (* s is optional *)
Eliom.Parameter.(int "i" ** any)                         (* the rest as an assoc list *)
Eliom.Parameter.(set string "s")                         (* /path?s=a&s=b *)
Eliom.Parameter.(list "l" (int "i"))                     (* /path?l[0]=1&l[1]=2 *)
Eliom.Parameter.(suffix (int "year" ** int "month"))     (* /path/2026/09 *)
Eliom.Parameter.(suffix_prod (int "year") (int "a"))     (* /path/2026?a=4 *)
```

A POST service declares both sides: `~meth:(Eliom.Service.Post (get_params, post_params))`.
Use `int64` for database ids, `unit` for no parameter, `user` for a custom type with a
string conversion.

## Links and forms

Links and forms are checked against the service they target (the `eliom-typed-markup`
skill covers the rest of TyXML):

```ocaml
let open Eliom.Content.Html.F in
a ~service:home [txt "Home"] ()
a ~service:user_page [txt "Profile"] userid
```

A form takes its field names from the service's parameters; a field of the wrong type or
name does not compile:

```ocaml
let open Eliom.Content.Html.F in
Form.post_form ~service:login (fun (name, password) ->
  [ fieldset
      [ label ~a:[a_label_for "name"] [txt "Name: "]
      ; Form.input ~a:[a_id "name"] ~input_type:`Text ~name Form.string
      ; Form.input ~input_type:`Password ~name:password Form.string
      ; Form.input ~input_type:`Submit ~value:"Log in" Form.string ] ]) ()
```

`Form.get_form` builds a GET form. `Form.input`, `Form.checkbox`, `Form.radio`,
`Form.select`, `Form.textarea`, `Form.file_input` and `Form.button` take the parameter name
and a `Form.param` (`Form.int`, `Form.int64`, `Form.string`, `Form.bool`, `Form.user`).

## Sessions and server-side state

State lives in Eliom references, whose value depends on a scope:

```ocaml
let visits = Eliom.Reference.eref ~scope:Eliom.Common.default_session_scope 0

let () =
  Eliom.Registration.Html.register ~service:page (fun () () ->
    let%lwt n = Eliom.Reference.get visits in
    let%lwt () = Eliom.Reference.set visits (n + 1) in
    Lwt.return (page_with_counter n))
```

Scopes, broadest to narrowest: `Eliom.Common.global_scope` (whole server), `site_scope`
(one site), `default_group_scope` (a group of sessions, typically one user),
`default_session_scope` (one browser, cookie-based), `default_process_scope` (one client
process; needs a client program). `Eliom.Reference.eref_from_fun` computes the initial
value lazily; `~persistent` stores the value on disk through ocsipersist with a
`Deriving_Json` codec; `~secure` restricts the reference to HTTPS sessions.
`Eliom.State.discard ~scope ()` closes a session, a group or a client process (logout).
Session timeouts are set in the configuration file or with `Eliom.State` (see
`references/config.md`).

Typical login: a POST pathless `Action` service checks the credentials and sets a
session-scoped reference (or the session group, which Ocsigen Start manages for you); the
page the user was on is then generated again, this time for a connected user.

## Temporary services and continuations

Services can be created at run time, inside a handler, for one user and one interaction:
the data of the previous steps is captured in the handler's closure. A multi-step form
(search, choose, pay) becomes a chain of pathless or attached services created on the fly,
each holding what was entered before; several interactions in several tabs, and the back
button, work by construction. Create them with `?max_use` or `?timeout` so they are
garbage collected, and register them with a session scope
(`register ~scope:Eliom.Common.default_session_scope ...`) so they belong to that user.

## Outputs and errors

- `Action`: perform the effect, then the current page is generated again;
  `~options:`NoReload` skips the redisplay.
- `Redirection`: the handler returns `Eliom.Registration.Redirection service`; the HTTP
  code is an option of `register`.
- `File`: the handler returns a file path. `Any`: the handler picks an output module and
  calls its `send`.
- Errors: `Eliom.Registration.set_exn_handler` installs a site-wide handler, typically
  matching `Eliom.Common.Eliom_404` and `Eliom.Common.Eliom_Wrong_parameter` to render error
  pages. Attached and pathless services fall back to their `~fallback` when a stale link
  arrives.

## Without a client program

- Event handlers on elements: `Eliom.Content.Html.F.Raw.a_onclick "..."` takes a JavaScript
  string. The non-`Raw` attributes expect OCaml functions and need a client program.
- Databases: any OCaml library; Ocsigen Start's template uses PG'OCaml (`ocsigen-start`).
- Internationalisation: ocsigen-i18n, `[%i18n key]` (`ocsigen-start`).

## Project setup

- `eliom-distillery -name mysite -template app.exe` creates a static executable project
  (dune, a main service, no configuration file); `-template app.lib` builds a library
  loaded by `ocsigenserver` with a configuration file. `eliom-distillery -list-templates`
  shows the templates.
- By hand: a dune executable with `eliom.server`, `ocsigenserver.ext.staticmod` and
  `ocsipersist-sqlite` in `libraries`, calling `Ocsigen.Server.start` with
  `Eliom.App.run ()` among the host's extensions. Details in `references/config.md`.

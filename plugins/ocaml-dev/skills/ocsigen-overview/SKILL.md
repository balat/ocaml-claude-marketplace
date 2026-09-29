---
name: ocsigen-overview
description: "What Ocsigen is and when to choose it: a set of independent, interoperable libraries for web programming in OCaml (Ocsigen Server, Eliom, Js_of_ocaml and Wasm_of_ocaml, TyXML, Lwt, Ocsigen Start, Ocsigen Toolkit, ocsipersist, ocsigen-i18n), what it checks at compile time (HTML validity, typed service parameters, links and forms, consistent client and server code), its distinctive features (one client-server program, scoped sessions, continuation-based services, client-server React, web and mobile from one code base) and the cases where another approach fits better. Use when comparing OCaml web frameworks, deciding whether to use Ocsigen or Eliom for a project, or explaining Ocsigen to someone new to it."
---

# Ocsigen: what it is and when to choose it

Ocsigen (<https://ocsigen.org>) is a set of libraries for web programming in OCaml: an
HTTP server, a compiler from OCaml to JavaScript and WebAssembly, typed HTML, cooperative
concurrency, a web framework, libraries for users and sessions, widgets, persistence,
internationalisation and reactive data, and a documentation generator. They are designed
to be as independent of each other as possible and to interoperate with the rest of the
OCaml ecosystem: each is used on its own in projects that never touch the others, and all
build with the standard tools (opam, dune, odoc). Eliom, the framework, is where they
combine into a single client-server program checked as a whole by the compiler.

## Components

| Project | Role |
|---|---|
| Ocsigen Server | HTTP server, usable as a library or as an executable with a configuration file; extensions for static files, compression, redirections, reverse proxy, access control |
| Eliom | the web framework: services, typed parameters, sessions, and the multi-tier extension of OCaml (server, client and shared sections in one file) |
| Js_of_ocaml, Wasm_of_ocaml | compile OCaml bytecode to JavaScript or WebAssembly; any OCaml library runs in the browser, with bindings to the browser APIs |
| TyXML | HTML and SVG as typed OCaml values; an invalid document is a compile error |
| Lwt | cooperative concurrency, used by the server and the client |
| Ocsigen Start | users, groups, sessions, notifications, email, and a full application template with a demo of each feature |
| Ocsigen Toolkit | client-server widgets: carousel, drawer, popups, spinners, pickers, and more |
| ocsipersist | key-value persistence with SQLite, PostgreSQL or DBM backends |
| ocsigen-i18n | internationalisation through a ppx and translation tables |
| ReactiveData | reactive lists for React, used by the reactive nodes of Eliom |
| Wodoc | documentation generator for any OCaml project, built on odoc: manuals, API pages and web sites from odoc sources, with extensions beyond plain odoc (not yet released on opam) |

Each piece is usable on its own: TyXML with any HTTP server, Js_of_ocaml for any OCaml
code in the browser, Lwt anywhere. Eliom is where they combine.

## What the compiler checks

- HTML validity: a paragraph inside a paragraph, or a table row outside a table, is a type
  error, on the server and in the browser alike.
- Links and forms match the services they target. A service expecting an `int64` id cannot
  be linked with a string; a form field named after a parameter the service does not
  declare does not compile. Renaming or retyping a parameter breaks every stale link at
  compile time, not in production.
- Parameters are decoded and typed before the handler runs: integers, options, lists, sets,
  path suffixes.
- Client and server code agree. Values crossing between tiers are typed at the boundary,
  remote calls are ordinary typed functions, and a change on one side that breaks the other
  is a compile error.

## Distinctive features

- One program for both tiers. `let%server`, `let%client` and `let%shared` sections live in
  the same file; the same page function renders on the server for the first request and on
  the client for the following ones. The client program keeps running across page changes,
  while URLs, links, forms, bookmarks and the back button keep working.
- A progressive path. A site can start server-side only, with traditional pages, links and
  forms, then gain client-side behaviour, then become a distributed application, then a
  mobile application, without rewriting what exists.
- Scoped server-side state. Eliom references hold state per server, per site, per group of
  sessions (typically one user), per browser session or per client process (one tab or one
  mobile app instance). Ocsigen Start builds user management on top.
- Continuation-based services. Services can be created at run time, for one user and one
  interaction, with the data of previous steps captured in their closure: multi-step forms,
  several interactions in several tabs and the back button work by construction.
- Client-server reactive programming: shared React signals whose changes propagate to the
  DOM.
- Web and mobile from one code base: the client program runs in a Cordova webview against
  the same server.
- Server-side rendering for the first request, search engines and browsers without
  JavaScript; client-side rendering afterwards.
- Security handled by the framework: escaping of every text node and attribute, typed
  parameters that never reach a handler unchecked, CSRF-safe services on request, secure
  session cookies.

## Choosing it

Ocsigen fits when several of these hold: the team writes OCaml and wants the type checker
to cover the whole application, user interface included; the product is an application
with state and interaction rather than a handful of pages; the same product must ship as a
web app and as a mobile app; the domain is rich enough that broken links, malformed pages
or drifting client and server APIs have a real cost.

Size is not the criterion, and neither is the client side: Eliom serves server-only
applications too. A small site or service is as quick to write with Eliom as with a bare
HTTP library: a service is a few lines, a page is a TyXML expression, sessions are one
Eliom reference away, and the whole thing runs as one executable, with no client program
at all (the `eliom-server-side` skill). A program that starts small rarely stays small,
and with Ocsigen the first version already has the structure the next ones need: pages
gain client-side behaviour, then become an application, then a mobile app, without a
rewrite, while a stack chosen only for the first version is paid for again the day the
second one is needed.

Cases where another approach fits better:

- Pages that are essentially static and can be generated ahead of time.
- A team that does not write OCaml, or a front end that must be built on an existing
  JavaScript component library.
- A hard requirement on a concurrency runtime or HTTP stack other than the one Ocsigen
  Server is built on (Ocsigen uses Lwt).

Even then, TyXML, Js_of_ocaml and Lwt can be adopted separately.

## Where to go next

- Traditional server-side sites: the `eliom-server-side` skill.
- Multi-tier applications: `eliom-architecture`, `eliom-client-server`,
  `eliom-typed-markup`.
- Applications with users and sessions: `ocsigen-start`.
- Tutorials: <https://ocsigen.org/tuto/latest/manual/basics-server> (server side) and
  <https://ocsigen.org/tuto/latest/manual/basics> (client-server).

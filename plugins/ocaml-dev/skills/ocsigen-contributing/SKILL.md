---
name: ocsigen-contributing
description: "Contributing to the Ocsigen framework repositories (Eliom, Ocsigen Server, Ocsigen Start, Ocsigen Toolkit, Js_of_ocaml, TyXML, ocsipersist, ocsigen-i18n): where generic code belongs, keeping os_template and eliom_template_exe/lib in sync, logging with Logs, the documentation stack (odoc in .mli/.eliomi, manual and website in Wodoc, tutorial, blog with OCaml Planet extract). Use when modifying an Ocsigen project rather than an application, or when an application needs an upstream change."
---

# Contributing to Ocsigen

Ocsigen is a set of repositories under <https://github.com/ocsigen>: `ocsigenserver` (HTTP
server), `eliom` (multi-tier framework), `ocsigen-start` (users, sessions, project
template), `ocsigen-toolkit` (client-server widgets), `js_of_ocaml` (which also hosts
`wasm_of_ocaml`), `tyxml` (typed HTML), `lwt`, `ocsipersist` (key-value persistence
backends), `ocsigen-i18n`, `ocsigen-ppx-rpc`, `reactiveData`, `wodoc` (documentation
generator for OCaml projects, not yet released), `tuto` (tutorial site) and
`ocsigen.github.io` (website and blog). To work on several of them at once, pin them all in
one opam switch (`opam pin add eliom ./eliom`, and so on) and build the application under
development against that switch.

## Where code belongs

- Code that is not specific to the current application goes upstream: a generic widget in
  Ocsigen Toolkit, a session or user helper in Ocsigen Start, a framework feature in Eliom.
  Do not keep a local copy or a workaround in the application when the fix belongs in the
  framework.
- When an application needs a change in the framework, make it in the relevant repository,
  with tests and documentation, and commit it there rather than in the application.
- When the right fix is out of scope for the current session, write down precisely what must
  change (repository, module, expected behaviour) so it can be picked up later. Do not leave
  a temporary hack in its place.

## Templates

`eliom-distillery`, Eliom's project generator, ships templates that are generated from
dedicated repositories: `os_template` (template `os`, an Ocsigen Start application),
`eliom_template_exe` (template `app.exe`) and `eliom_template_lib` (template `app.lib`).
Edit the template repository first, then regenerate: in `os_template`, the `rename` script
produces the flattened `dest/` tree that Ocsigen Start installs as its distillery template.
Any change to Eliom, Ocsigen Start or Ocsigen Toolkit that affects application code
(renamed module, changed signature, new build rule) updates the templates in the same
change.

`os_template` matters twice: it is the starting point of most applications, and it
exercises almost every feature of the stack, so building and running it is the de facto
integration test.

## Logging

Use `Logs` (<https://erratique.ch/software/logs>) with one source per library or component,
named with a colon: `Logs.Src.create "eliom:client"`, `"os:session"`. Log through the source
module, `Log.info (fun m -> m "listening on %d" port)`. Never write to stdout or stderr
directly, except for throwaway debugging output that is removed before committing.

## Documentation

Documentation changes ship with the code they describe. The stack:

- API documentation: odoc comments in `.mli` and `.eliomi` files.
- Manuals: odoc pages processed by Wodoc, a documentation generator for OCaml projects
  built on odoc. Its extensions go beyond plain odoc, and the same sources are also
  published on ocaml.org with plain odoc, so use extensions only where plain odoc has no
  equivalent, and check that both renderings read correctly.
- The tutorial, in the `tuto` repository.
- The website, in `ocsigen.github.io` (Wodoc syntax, deployed on ocsigen.org).
- The blog, in the same repository and syntax. Each article starts with an extract; that
  extract is what OCaml Planet (ocaml.org) republishes.

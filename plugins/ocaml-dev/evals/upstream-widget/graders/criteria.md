---
type: llm
weight: 1
---

A successful response:
- says the generic widget belongs in Ocsigen Toolkit and the `Manip` fix in the Eliom
  repository, not as local patches in the application;
- mentions updating the templates (`os_template`, `eliom_template_exe` and `eliom_template_lib`, edited first
  and then regenerated) when an Eliom signature changes, and building/running `os_template`
  as the integration test;
- covers documentation: odoc comments in `.mli`/`.eliomi`, manual pages that must render
  both on ocsigen.org (Wodoc) and on ocaml.org (plain odoc);
- for the unfinished Eliom fix, recommends documenting precisely what must be done rather
  than leaving a temporary hack.

---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

I have a small browser-only OCaml program compiled with js_of_ocaml (no server, no Eliom):
a single `main.ml` that draws a canvas animation and reacts to keyboard events with
`Dom_html` and `Js_of_ocaml_lwt.Lwt_js_events`. Frames stutter when I hold a key down, and
I suspect I create a new event loop on every keypress. How should I structure the event
handling and the animation loop? A short skeleton is enough.

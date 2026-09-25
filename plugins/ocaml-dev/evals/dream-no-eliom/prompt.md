---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

I'm building a small internal tool with Dream (the OCaml web framework) and TyXML for the
HTML, no JavaScript at all, server-rendered pages only. How should I organise routes,
handlers and templates across files, and what is the idiomatic way to keep the current user
in the Dream session? A short skeleton is enough.

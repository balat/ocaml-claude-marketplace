---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

I want a classic server-rendered web site in OCaml with Eliom, no client-side program at
all: a home page, a login form (name and password, POST), a per-user page at
`/users/<id>` with a visit counter kept in the session, and a logout link. Show me the
service definitions, the form, the session state, how errors on a bad user id are handled,
and how to build and run the thing with dune.

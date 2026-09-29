---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

We are a three-person OCaml team about to build an internal booking tool (rooms, multi-step
reservation, user accounts, later a mobile version for the facility staff). A colleague
says we should just wire an HTTP library with TyXML templates by hand; another pushes for
Ocsigen. What would Ocsigen actually give us here that the hand-wired approach would not,
what does it cost us, and in which situations would you advise against it?

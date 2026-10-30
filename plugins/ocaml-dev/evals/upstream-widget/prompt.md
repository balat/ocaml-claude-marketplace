---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

While working on my Eliom application I wrote a generic "date range picker" widget on top of
`Ot.Calendar`, and I also had to change the signature of `Manip.replaceChildren` in Eliom
itself to fix a bug. Both changes currently live as patches inside my application repo.
Where should each of them go, what else do I have to update so that other Ocsigen users are
not broken, and how should the documentation be handled? I don't have time to finish the
Eliom part properly this week.

---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

Our OCaml 5 service uses Eio (Eio_main.run, Eio.Switch, Eio.Fiber). A handler spawns a
fiber per incoming request with `Fiber.fork ~sw`, and when one request raises, the whole
switch is cancelled and every other in-flight request fails. How do I isolate failures per
request while keeping structured concurrency? Show the pattern in a few lines.

---
type: llm
weight: 1
---

A successful response stays within Eio (a nested `Switch.run` per request, or
`Fiber.fork_daemon`/`Fiber.fork` with a per-request switch, catching exceptions inside the
fiber) and does not recommend rewriting with Lwt or mixing Lwt idioms (`Lwt.async`,
`Lwt.catch`) into the Eio code.

---
type: llm
weight: 1
---

A successful response:
- replaces `ignore (refresh_cache ())` with `Lwt.async` (or `Lwt.dont_wait`) and explains
  that a rejected promise nobody waits on is dropped silently, and that
  `Lwt.async_exception_hook` should be set to log;
- replaces `try ... with` around promise chains with `Lwt.catch` (or `try%lwt`), explaining
  that `try` only catches exceptions raised before the first pending promise;
- points out that the `notify` calls are independent and can run concurrently
  (`Lwt_list.iter_p`) unless ordering matters, or justifies keeping `iter_s`;
- unifies the binding style (`let*` from `Lwt.Syntax` or `let%lwt`, one of them) across the
  module.

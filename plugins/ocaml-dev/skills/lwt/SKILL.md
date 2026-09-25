---
name: lwt
description: "Lwt cooperative concurrency for OCaml: promise binding styles (let%lwt, let*), Lwt.async, racing and joining (pick, choose, join, both), Lwt.catch, try_bind and finalize, cancellation, Lwt_unix and Lwt_list, avoiding blocking calls, exceptions versus rejected promises. Use when writing or reviewing Lwt code on servers or Js_of_ocaml clients, choosing between Lwt idioms, or debugging hangs, lost exceptions or a blocked event loop."
---

# Lwt

Lwt (<https://ocsigen.org/lwt>) is a cooperative concurrency library. A value of type
`'a Lwt.t` is a promise: pending,
fulfilled with an `'a`, or rejected with an exception. A single event loop runs everything;
a computation yields only when it waits on a pending promise. Two consequences drive most of
the rules below: a blocking call freezes the whole program, and a rejected promise nobody
waits on disappears unless something is set up to observe it.

The `_ Lwt.t` in a signature is information: a function returning `'a Lwt.t` may take time
or perform I/O, one returning `'a` does not. Effect-based libraries do not express this in
types; with Lwt the compiler checks it. Keep that signal honest: do not call
`Lwt_main.run` inside library code, and do not hide a promise behind `unit`.

## Why Lwt

Lwt is a cooperative concurrency library for OCaml 4.14 and 5. Compared with effect-based
libraries such as Eio:

- **Typed asynchrony**: a function that may suspend returns an `'a Lwt.t`, so the compiler
  shows and checks where waiting can happen; the price is the monadic style
- **Runs everywhere OCaml runs**: native and bytecode, js_of_ocaml and wasm_of_ocaml in the
  browser, MirageOS unikernels, OCaml 4.14 as well as 5
- **The largest ecosystem**: Ocsigen, Dream, cohttp-lwt, Irmin, MirageOS and most opam
  packages with a concurrency dependency are built on Lwt
- **Interoperation**: `Lwt_eio` runs Lwt libraries inside an Eio program, and the reverse

## Binding syntax

Two styles are in common use; pick one per project and use it everywhere. A file that
mixes `let%lwt`, `let*`, `>>=` and `Lwt.bind` is a review finding.

With the `lwt_ppx` preprocessor (`(preprocess (pps lwt_ppx))` in `dune`):

```ocaml
let%lwt user = fetch_user id in
let%lwt perms = fetch_permissions user in
Lwt.return (user, perms)
```

`match%lwt`, `if%lwt`, `try%lwt ... with`, `for%lwt`, `while%lwt` and `[%lwt.finally]` cover
the other control structures.

With the standard binding operators, no preprocessor:

```ocaml
let open Lwt.Syntax in
let* user = fetch_user id in
let+ perms = fetch_permissions user in
(user, perms)
```

`let*` binds, `let+` maps, and `and*` or `and+` start two promises together (`Lwt.both`).
`Lwt_result.Syntax` provides the same operators for `('a, 'e) result Lwt.t`.

Return with `Lwt.return x`, or the allocation-free constants `Lwt.return_unit`,
`Lwt.return_none`, `Lwt.return_nil`, `Lwt.return_true`, `Lwt.return_false`, and
`Lwt.return_ok`, `Lwt.return_error`, `Lwt.return_some`.

## Errors

- Inside a callback (the body of a `let%lwt`, of `Lwt.catch`, of `Lwt.async`), `raise e`
  rejects the promise. `Lwt.fail e` builds a rejected promise where an expression of type
  `_ Lwt.t` is needed outside a callback.
- `try ... with` around Lwt code only catches exceptions raised before the first pending
  promise; anything raised later in the chain escapes it. Use `Lwt.catch` (or `try%lwt`):

  ```ocaml
  Lwt.catch
    (fun () -> Db.find id)
    (function
      | Not_found -> Lwt.return_none
      | e -> raise e)
  ```

- Match specific exceptions and re-raise the rest. A catch-all `| _ ->` hides programming
  errors and cancellation.
- `Lwt.try_bind (fun () -> p) on_success on_failure` handles both outcomes;
  `Lwt.finalize (fun () -> p) cleanup` runs `cleanup` whatever happens.
- Fire-and-forget: `Lwt.async (fun () -> work ())`. If `work` fails, the exception is passed to
  `!Lwt.async_exception_hook`, which by default prints it and terminates the program. Set
  the hook once at startup (log through `Logs`, decide whether to exit). `Lwt.dont_wait f
  handler` gives a per-call handler. Never `ignore (p : _ Lwt.t)`: the promise still runs,
  but a rejection is dropped silently.

## Concurrency

Sequencing is the default: `let%lwt a = f () in let%lwt b = g () in ...` starts `g` only
when `f` has resolved. When calls are independent (two RPCs, two queries), start them
together:

```ocaml
let%lwt a, b = Lwt.both (f ()) (g ()) in
```

- `Lwt_list.map_p`, `iter_p`, `filter_p` run over a list concurrently; `map_s`, `iter_s` run
  sequentially. Use the `_s` forms when order matters or a resource must not be hammered;
  bound concurrency with `Lwt_pool`.
- `Lwt.join [p1; p2]` waits for unit promises; `Lwt.both` returns both values.
- Racing: `Lwt.pick [p1; p2]` returns the first resolved promise and cancels the others;
  `Lwt.choose` returns the first without cancelling. Timeouts:
  `Lwt_unix.with_timeout seconds (fun () -> op ())` raises `Lwt_unix.Timeout`.
- Cancellation (`Lwt.cancel`, and the losers of `Lwt.pick`) rejects a promise with
  `Lwt.Canceled` and is easy to get wrong across resource boundaries. Only race promises that
  are safe to cancel; protect a promise with `Lwt.protected` or `Lwt.no_cancel` when its
  cancellation would leave state half-updated. For new code, prefer explicit signalling
  (`Lwt_switch`, `Lwt_condition`) over relying on cancellation semantics.
- Long CPU-bound loops must yield with `Lwt.pause ()` now and then, or run elsewhere
  (`Lwt_preemptive.detach`, or an OCaml 5 domain), otherwise nothing else progresses.

## Synchronisation

- Hand-made promises: `let p, resolver = Lwt.wait ()` (or `Lwt.task ()` for a cancellable
  one), then `Lwt.wakeup_later resolver v` or `Lwt.wakeup_later_exn resolver e`.
- `Lwt_mutex` is needed only when a critical section spans a bind: without preemption, code
  between two binds already runs atomically.
- `Lwt_condition`, `Lwt_mvar`, `Lwt_stream` for producer/consumer patterns; `Lwt_switch` to
  tie resources to a lifetime.

## Never block the loop

| Blocking | Cooperative |
|---|---|
| `Unix.sleep`, `Thread.delay` | `Lwt_unix.sleep` (`Lwt_js.sleep` in the browser) |
| `Unix.read`, `Unix.write`, `input_line` | `Lwt_unix.read`, `Lwt_io.read_line`, `Lwt_io` channels |
| `Unix.system`, `Sys.command` | `Lwt_process` |
| `Unix.gethostbyname` | `Lwt_unix.gethostbyname` |
| a long pure computation | chunk it with `Lwt.pause`, or `Lwt_preemptive.detach` |

`Lwt_main.run` appears exactly once, at the program entry point. Nested or repeated calls
are a bug.

## Js_of_ocaml

The same API runs in the browser (`js_of_ocaml-lwt`). `Lwt_js.sleep` replaces `Lwt_unix`,
`Lwt_js_events` binds DOM events (`clicks`, `changes`, ...; the `s` suffix loops over
repeated events, the singular form waits for one). There is no `Lwt_main.run`: the browser
drives the loop, and an unhandled rejection reaches `Lwt.async_exception_hook`, which logs to
the console. The `Lwt_js_events.clicks` loop catches an exception escaping its body, logs it
to the console and carries on, so the user sees nothing: catch inside the body and show a
message.

## Review checklist

- One binding style in the project.
- No blocking Unix call, no `Lwt_main.run` outside `main`.
- Every fire-and-forget goes through `Lwt.async` or `Lwt.dont_wait`, and the exception hook
  is set.
- `Lwt.catch` or `try%lwt`, not `try ... with`, around promise chains; specific exceptions;
  others re-raised.
- Independent calls started together (`Lwt.both`, `Lwt_list.map_p`), dependent ones
  sequenced.
- Only cancel-safe promises inside `Lwt.pick`.

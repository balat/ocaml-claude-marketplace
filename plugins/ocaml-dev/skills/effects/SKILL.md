---
name: effects
description: "OCaml 5 algebraic effects design patterns. Use when Claude needs to: (1) Design APIs that interact with effect-based schedulers, (2) Decide between effects vs exceptions, (3) Integrate libraries with effect-based schedulers (Eio, Miou, Picos, affect) or run them under Lwt, (4) Handle suspension vs error cases in streaming code, (5) Understand the layered effect design principle"
---

# OCaml 5 Effects Design

## Core Principle

**Effects for control flow, exceptions for errors.**

| Concern | Mechanism | Example |
|---------|-----------|---------|
| Suspension (wait for data) | Effects | `perform Block`, `perform Yield` |
| Error (EOF, malformed) | Exceptions | `raise End_of_file`, `Invalid_argument` |

## Layered Design

Effects should be handled at the **source level**, not in protocol parsers:

```
Application
    ↓
Protocol parser (Binary.Reader, Cbor, etc.)
    ↓  raises exceptions on EOF/error
bytesrw (effect-agnostic)
    ↓  just calls pull function
Source (Eio flow, affect fd, Unix fd)
    ↓  performs effects for suspension
Effect handler (Eio scheduler, affect runtime)
```

### Why This Matters

- **Parsers stay pure**: No effect dependencies, easy to test
- **Sources control blocking**: Handler decides wait vs fail vs timeout
- **Composability**: Same parser works with any effect system

## Effect Libraries

Effects are the mechanism; several schedulers build on it. Follow the one the project
uses, and design libraries so that they work under any of them (see Layered Design).

### Eio

Effects are internal to the scheduler. User code looks synchronous:

```ocaml
(* Reading blocks via internal effects *)
let data = Eio.Flow.read flow buf
```

### affect

Explicit effects for fiber scheduling:

```ocaml
type _ Effect.t +=
| Block : 'a block -> 'a Effect.t   (* suspension *)
| Await : await -> unit Effect.t    (* wait on fibers *)
| Yield : unit Effect.t             (* cooperative yield *)

(* Block has callbacks for scheduler integration *)
type 'a block = {
  block : handle -> unit;      (* register blocked fiber *)
  cancel : handle -> bool;     (* handle cancellation *)
  return : handle -> 'a        (* extract result *)
}
```

### Miou, Picos, Domainslib, Moonpool

- **Miou** (Robur): a small effects-based scheduler for systems programming; fibers and
  domains with a minimal API.
- **Picos**: an interoperability framework: a library written against Picos runs under
  any Picos-compatible scheduler.
- **Domainslib** and **Moonpool**: task pools for CPU-bound parallelism on domains,
  with or without effects.

### Lwt

Lwt predates effects and stays monadic: a suspension is a pending promise, not a performed
effect, so the type of a function (`'a Lwt.t`) says whether it may suspend, which effects do
not express in types. It runs on OCaml 4.14 and in the browser. A library written in the
layered style below works under Lwt too: the pull function returns a promise, or the
Lwt program hosts an Eio loop with `Lwt_eio` (`Lwt_eio.run_lwt`, `Lwt_eio.run_eio`). See
the `lwt` skill.

### bytesrw

Effect-agnostic streaming. The pull function you provide can perform any effects:

```ocaml
(* bytesrw just calls your function *)
let reader = Bytesrw.Bytes.Reader.make my_pull_fn

(* If my_pull_fn performs Eio effects, they propagate *)
(* If my_pull_fn performs affect Block, they propagate *)
(* bytesrw doesn't care - it just calls the function *)
```

## Integration Pattern

Wire effect-performing sources to effect-agnostic libraries:

```ocaml
(* With Eio *)
let reader = Bytesrw_eio.bytes_reader_of_flow flow in
let r = Binary.Reader.of_reader reader in
parse r  (* Eio effects happen in pull function *)

(* With affect *)
let pull () =
  let buf = Bytes.create 4096 in
  perform (Block { block; cancel; return = fun _ ->
    Slice.make buf ~first:0 ~length:n })
in
let reader = Bytesrw.Bytes.Reader.make pull in
parse (Binary.Reader.of_reader reader)
```

## When EOF Is Reached

`Slice.eod` from bytesrw means **final EOF** - no more data will ever come.

- Not "data not ready" (that's handled by effects in pull function)
- Not "try again later" (source already waited via effects)
- Parser should raise exception (EOF is an error condition)

## Anti-Patterns

**Don't**: Define `Await` effect in protocol parsers
```ocaml
(* Wrong: the parser should not know about suspension *)
let get_byte t =
  if no_data then perform Await; ...
```

**Do**: Let the source handle suspension
```ocaml
(* Right: the parser just reads, the source handles waiting *)
let get_byte t =
  match pull_next_slice t with  (* may perform effects *)
  | Some slice -> ...
  | None -> raise End_of_file   (* true EOF *)
```

## Handlers and Caveats

- `Effect.Deep` handlers resume a continuation once; `Effect.Shallow` handlers give
  back control after each resumption, which suits schedulers that reinstall a handler
  at every step. Most application code needs neither: the scheduler owns the handlers.
- Continuations do not cross domains, and an unhandled effect raises
  `Effect.Unhandled`: a library that performs effects must document which handler it
  expects to run under.
- Since OCaml 5.3, `match ... with` accepts `effect` patterns, so a handler can be written
  without `Effect.Deep.match_with`; effects are still declared with `type _ Effect.t += ...`.

## References

- Eio: https://github.com/ocaml-multicore/eio
- affect: https://github.com/dbuenzli/affect
- Miou: https://github.com/robur-coop/miou
- Picos: https://github.com/ocaml-multicore/picos
- Lwt_eio: https://github.com/ocaml-multicore/lwt_eio
- bytesrw: https://erratique.ch/software/bytesrw
- OCaml effects tutorial: https://github.com/ocaml-multicore/ocaml-effects-tutorial
- Retrofitting Effect Handlers onto OCaml (PLDI 2021): https://dl.acm.org/doi/10.1145/3453483.3454039
- Collège de France 2023-2024 lectures on control structures: https://xavierleroy.org/CdF/2023-2024/

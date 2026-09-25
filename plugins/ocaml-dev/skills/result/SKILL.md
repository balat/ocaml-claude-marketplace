---
name: result
description: "OCaml Result type patterns with the standard library (Result.Syntax since OCaml 5.4). Use when Claude needs to: (1) Handle errors with Result types, (2) Chain Result operations with let*, (3) Extract values from Ok/Error, (4) Refactor code using local let* bindings to use Result.Syntax"
---

# OCaml Result Patterns

OCaml 5.4 and later provide `Result.Syntax` for monadic chaining; `Result.get_ok` and `Result.get_error` extract values (since 4.08).

## Result.Syntax

Use `open Result.Syntax` to get `let*` and `let+` bindings:

```ocaml
open Result.Syntax

let process request =
  let* req = validate request in
  let* auth = authenticate req in
  let* _ = authorize auth in
  execute req
```

On OCaml 5.4 and later, `open Result.Syntax` replaces a local `let ( let* ) = Result.bind`. On earlier versions, define the operators once in a small `Result_syntax` module and open it, rather than redefining them in every file.

## Extracting Values

| Function | Behavior on Error |
|----------|-------------------|
| `Result.get_ok r` | Raises `Invalid_argument` |
| `Result.get_error r` | Raises `Invalid_argument` |
| `Result.value r ~default` | Returns default |

Use `Result.get_ok` only when failure is a programming error:

```ocaml
(* Startup/config - crash on failure is intentional *)
let config = Result.get_ok (Config.load ())

(* Test setup - failure means test bug *)
let client = Result.get_ok (Tls.Config.client ~authenticator ())
```

## Custom get_ok

Only define custom `get_ok` when you need different exception behavior:

```ocaml
(* Raises domain-specific Protocol_error instead of Invalid_argument *)
let get_ok = function
  | Ok x -> x
  | Error e -> raise (Protocol_error e)
```

If you just want `Invalid_argument`, use `Result.get_ok` directly.

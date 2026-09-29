---
name: code-style
description: "OCaml coding style and refactoring patterns. Use when the user asks to tidy, clean up, refactor, or improve OCaml code, reviewing code quality, enforcing naming conventions, or reducing complexity."
---

# OCaml Code Style

## Core Philosophy

1. **Interface-First**: Design `.mli` first. Clean interface > clever implementation.
2. **Modularity**: Small, focused modules. Compose for larger systems.
3. **Simplicity (KISS)**: Clarity over conciseness. Avoid obscure constructs.
4. **Explicitness**: Explicit control flow and error handling. No exceptions for recoverable errors.
5. **Purity**: Prefer pure functions. Isolate side-effects at edges.
6. **No `Obj.magic`**: Breaks type safety. Always a better solution.

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | `lowercase_underscores` | `user_profile.ml` |
| Modules | `Capitalised_underscores` | `User_profile` |
| Types | `snake_case`, primary type is `t` | `type user_profile`, `type t` |
| Values | `snake_case` | `find_user`, `create_channel` |
| Variants | `Capitalised_underscores` | `Waiting_for_input`, `Processing_data` |

**Lookups that may fail**: make the two outcomes visible in the name and keep one
convention across the project. The Stdlib pairs `find` (raises) with `find_opt`; Base pairs
`find` (option) with `find_exn`; other code bases use `find_*` for `option` and `get_*` for
a value that must exist. Follow the one already in use.

**Avoid**: Long names with many underscores (`get_user_profile_data_from_database_by_id`).

## Refactoring Patterns

### Option/Result Combinators

```ocaml
(* Before *)
match get_value () with Some x -> Some (x + 1) | None -> None

(* After *)
Option.map (fun x -> x + 1) (get_value ())
```

Prefer: `Option.map`, `Option.bind`, `Option.value`, `Result.map`, `Result.bind`

### Monadic Syntax (let*/let+)

```ocaml
(* Before - nested matches *)
match fetch_user id with
| Ok user -> (match fetch_perms user with Ok p -> Ok (user, p) | Error e -> Error e)
| Error e -> Error e

(* After *)
let open Result.Syntax in   (* OCaml 5.4+; define the operators once on older versions *)
let* user = fetch_user id in
let+ perms = fetch_perms user in
(user, perms)
```

### Pattern Matching Over Conditionals

```ocaml
(* Before *)
if x > 0 then if x < 10 then "small" else "large" else "negative"

(* After *)
match x with
| x when x < 0 -> "negative"
| x when x < 10 -> "small"
| _ -> "large"
```

## Function Design

**Keep functions small**: One purpose per function; extract a helper as soon as a function
does two things.

**Avoid deep nesting**: several nested levels of `match`/`if` are the signal to extract
helpers or to match on a tuple.

**High complexity signal**: Many branches = split into focused helpers.

```ocaml
(* Bad - high complexity *)
let check x y z =
  if x > 0 then if y > 0 then if z > 0 then ... else ... else ... else ...

(* Good - factored *)
let all_positive x y z = x > 0 && y > 0 && z > 0
let check x y z = if not (all_positive x y z) then "invalid" else ...
```

## Error Handling

**Use `result` for recoverable errors**. Exceptions only for programming errors.

**Never catch-all**:
```ocaml
(* Bad *)
try f () with _ -> default

(* Good *)
try f () with Failure _ -> default
```

**Don't silence warnings**: Fix the issue, don't use `[@warning "-nn"]`.

## Libraries

Keep the libraries the project already uses. `Printf` and `Format` are Stdlib and type-safe,
`Fmt` adds combinators; `Str` is Stdlib but keeps global state, `Re` is pure and composable;
`yojson` and `jsont` are both legitimate JSON choices. None of these is a reason to add a
dependency or to rewrite working code during a refactoring; raise the question separately
if a switch would pay off.

## Module Hygiene

**Abstract types**: Keep `type t` abstract. Expose smart constructors.

```ocaml
(* Good - .mli *)
type t
val create : name:string -> t
val name : t -> string
val pp : Format.formatter -> t -> unit
```

**Avoid generic names**: Not `Util`, `Helpers`. Use `String_ext`, `Json_codec`.

## API Design

**Avoid boolean blindness**:
```ocaml
(* Bad *)
let create_widget visible bordered = ...
let w = create_widget true false  (* What does this mean? *)

(* Good *)
type visibility = Visible | Hidden
let create_widget ~visibility ~border = ...
```

## Comments and Documentation

- Documentation lives in the `.mli`; every exported value has a doc comment that describes
  the behaviour a caller can observe, not the implementation.
- Every optional argument states its default.
- Implementation comments explain what the code cannot: an invariant, a workaround, a
  reference. Delete comments that restate the code, section banners and commented-out code.
- Match the project's documentation voice. The Stdlib style uses imperative sentences with
  `@param` and `@raise` tags; the manpage style opens with `[f x y] is ...` and is described
  in the `doc-style` skill. Do not convert a code base from one to the other while tidying.

```ocaml
(* Bad: describes the implementation *)
(** Splits on commas and builds the record, fast. *)
val parse : string -> t

(* Good: describes the behaviour *)
val parse : string -> t
(** [parse s] is the record encoded in [s]. Parsing is linear in the length of
    [s]. *)
```

## Red Flags

- Match that just rewraps: `Some v -> Some (f v) | None -> None`
- Nested Result/Option matches: use let*/let+
- Deep if/then/else: pattern matching
- Missing `pp` function on types
- Unlabeled boolean parameters
- `Obj.magic` anywhere
- Doc comments that describe the implementation rather than the behaviour
- Comments inside an implementation that restate the code
- An exported value with no doc comment

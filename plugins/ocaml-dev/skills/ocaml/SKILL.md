---
name: ocaml
description: "OCaml development guidance for building robust, type-safe applications. Use when Claude needs to: (1) Write OCaml code following modern best practices, (2) Design module interfaces (.mli files), (3) Handle errors with result types, (4) Work with the dune build system, (5) Choose libraries for concurrency, web, databases, serialisation, parsing, logging or command lines and weigh their trade-offs, or any other general OCaml development task"
---

# OCaml Development

## Core Philosophy

1. **Interface-First Design**: Design the `.mli` file first. A clean interface matters more than clever implementation.
2. **Modularity**: Build small, focused modules that do one thing well. Compose them for larger systems.
3. **Simplicity (KISS)**: Prioritize clarity over conciseness. Avoid obscure constructs.
4. **Explicitness**: Make control flow and error handling explicit. Avoid exceptions for recoverable errors.
5. **No `Obj.magic`**: It breaks type safety. There is always a better solution.

## Build System and Tooling

- **Build**: `dune`, with `dune-project` generating the opam files.
- **Formatting**: if the project has a `.ocamlformat`, run `dune fmt` before committing; do not introduce one into a project that formats by hand without asking.
- **Libraries**: follow the project's existing choices before anything else; a dependency added to rewrite working code is a cost, not an improvement. For a new project, the common options and their trade-offs:

| Need | Options | Trade-offs |
|------|---------|------------|
| Concurrency | Lwt, Eio, Miou, Async; Domainslib or Moonpool for CPU parallelism; Saturn and Kcas for lock-free structures | Lwt: monadic style, so a function that may suspend is marked by its type (`'a Lwt.t`), runs on OCaml 4.14 and in the browser (js_of_ocaml), the widest ecosystem (Ocsigen, Dream, cohttp-lwt, MirageOS). Eio: direct style on OCaml 5 effects, io_uring backend; like every effect-based library, suspension is invisible in types. Miou: effects with a smaller API. Async: Jane Street's, with Core. See the `lwt` and `eio` skills. |
| HTTP and web frameworks | cohttp (lwt or eio), httpaf/h2/httpun, Dream, Eliom (Ocsigen), Opium, Piaf (client) | Follows the concurrency choice: cohttp has both backends, Dream and Eliom are Lwt-based. Dream is a lightweight server-side framework; Eliom is a full web framework with typed services, links and forms, usable server-side only or for client-server applications (next row). |
| Web and mobile applications | Eliom (Ocsigen) | One OCaml program for the server and the client, compiled to JavaScript or WebAssembly; HTML, links and forms checked at compile time against typed services; scoped sessions; the same code base ships as a mobile app (Cordova). See the `ocsigen-overview` skill. |
| Databases | SQL: caqti (one interface, drivers for PostgreSQL, SQLite, MariaDB), pgocaml (PostgreSQL, SQL checked at build time by `pgocaml_ppx`), postgresql (libpq bindings), pgx (pure OCaml), sqlite3, mariadb, mysql; key-value and other: Irmin (versioned, Git-like store), ocsipersist (key-value with SQLite, PostgreSQL or DBM backends), lmdb, redis | caqti follows the concurrency library (Lwt, Eio, Async, Miou) and abstracts the engine, with `ppx_rapper` for typed queries; pgocaml needs the database at build time and gives fully typed queries in return; pgx has no C dependency; Irmin is a mergeable store with history rather than a SQL database. |
| Serialisation | JSON: yojson (with ppx_deriving_yojson or ppx_yojson_conv), jsont, ezjsonm, atdgen; YAML: yaml; TOML: otoml, toml; XML: xmlm, xml-light, markup; S-expressions: sexplib, csexp; binary: bin_prot, cbor, msgpck; Protobuf and gRPC: ocaml-protoc, grpc | yojson is the most widespread; jsont gives typed bidirectional codecs (see the `jsont` skill); atdgen generates codecs for several languages from one schema; xmlm and jsonm are streaming. |
| Parsing | menhir with ocamllex or sedlex, angstrom, re, uri | menhir for grammars, angstrom for parser combinators over binary or text, re for regular expressions, uri for URIs. |
| Formatting | Printf and Format (Stdlib), Fmt | Both are type-safe; Fmt adds combinators and terminal styling. |
| Logging | Logs, or the project's own | See the `logs` skill. |
| Command lines | cmdliner, Arg (Stdlib), Clap; notty and lambda-term for terminal interfaces, progress for progress bars | cmdliner for subcommands and man pages (see the `cmdliner` skill); Arg for a handful of flags. |
| Cryptography and TLS | mirage-crypto, tls (pure OCaml), ssl (OpenSSL), digestif (hashes), x509 and ca-certs, argon2 or safepass for passwords | tls and mirage-crypto have no C dependency and run under Lwt, Eio, Miou or MirageOS; ssl binds OpenSSL. |
| Dates, paths, files | ptime, mtime, calendar, timedesc; fpath and bos; Unix (Stdlib) | ptime for POSIX time, mtime for monotonic clocks, calendar and timedesc for calendars and time zones. |
| Stdlib extensions | containers, base and core (Jane Street), batteries; zarith for arbitrary precision; owl for numerics | containers extends the Stdlib without replacing it; base and core replace it and come with the Jane Street ppx ecosystem. |
| Browser and JavaScript | js_of_ocaml and wasm_of_ocaml, brr, gen_js_api, melange | js_of_ocaml compiles bytecode, any library works; brr and the Js_of_ocaml bindings cover the browser APIs; melange compiles to JavaScript with its own toolchain. |
| Graphical interfaces | lablgtk3, bogue, tsdl, raylib | GTK bindings, a pure OCaml toolkit, SDL and raylib bindings. |
| Tests | Alcotest, OUnit2, ppx_expect, QCheck, Crowbar, cram | See the `testing` and `fuzz` skills. |

`references/ecosystem.md` gives more options per category and how to weigh adoption.
## Module Interface Design

### Documentation

Every exported value gets a doc comment, in the `.mli`, not the `.ml`. Two documentation
voices are common in the ecosystem; match the one the project already uses:

- The Stdlib and OCaml manual style: an imperative sentence (`Return the length of ...`),
  `@param`, `@raise` and `@since` tags.
- The manpage style used by many opam libraries: `[f x y] is ...`, full declarative
  sentences, no tags. The `doc-style` skill describes it in detail.

Every `.mli` file starts with a synopsis, then a blank line, then the description.

```ocaml
(** User accounts and profiles.

    Users are workspace members. A user is identified by an {!type:id} that is
    stable for the lifetime of the account. *)
```

For types, describe what the values represent, not their representation.

### Implementation Comments

Implementations carry comments only where the code does not say it already: a spec
citation, a non-local invariant, a deliberate workaround, a justification for an unsafe
operation. Documentation lives in the `.mli`.

### Standard Interface for Data Types

For modules with a central type `t`, provide these functions where applicable:

| Function | Purpose |
|----------|---------|
| `val make : ... -> t` (or `create`, `v`, `of_*`, as the project names them) | Constructor; a constructor that can fail returns a `result` |
| `val pp : Format.formatter -> t -> unit` | Pretty-printer for logging and debugging |
| `val equal : t -> t -> bool` | Structural equality |
| `val compare : t -> t -> int` | Comparison for sorting |
| `val of_json : json -> (t, string) result`, `val to_json : t -> json` | Conversions, with the project's JSON library |
| `val validate : t -> (t, string) result` | Validate data integrity |

### Abstract Types

Keep types abstract (`type t`) when possible. Expose smart constructors and accessors instead of record fields to maintain invariants.

## Error Handling

Use `result` type for recoverable errors. Reserve exceptions for programming errors (e.g., `Invalid_argument`).

### Central Error Type

Define a comprehensive error type in `lib/error.ml`:

```ocaml
(* In lib/error.mli *)
type t = [
  | `Api of string * string
  | `Json_parse of string
  | `Network of string
  | `Msg of string
]

val pp : Format.formatter -> t -> unit
```

### Error Helper Pattern

```ocaml
let err_api code msg = Error (`Api (code, msg))
let err_parse msg = Error (`Json_parse msg)

let find_user_id fields =
  match List.assoc_opt "id" fields with
  | Some id -> Ok id
  | None -> err_parse "Missing user ID"
```

### Rules

- Never use `try ... with _ -> ...`. Match specific exceptions.
- For unrecoverable startup errors, fail with a clear message:

```ocaml
let tls_config =
  match Tls.Config.client ~authenticator () with
  | Ok config -> config
  | Error (`Msg msg) -> failwith (Printf.sprintf "Failed to create TLS config: %s" msg)
```

## Function Design

- **Keep functions small**: One function, one purpose. Extract a helper when a function does more than one thing.
- **Avoid deep nesting**: nested `match`/`if` several levels deep is the signal to extract helpers or to match on a tuple.
- **Prefer purity**: Isolate side-effects at edges (`bin/`, `lib/ui/`).
- **Composition over abstraction**: Favor small concrete functions over deep abstractions.
- **Data-oriented**: Operate on simple, immutable data structures.
- **No premature generalization**: Solve the problem at hand, avoid unnecessary complexity.

## Logging

Use one logging library across the project, with a source per module so that levels can be
tuned per component. Logs is the most common choice; the `logs` skill gives the idiom, the
levels and the reporter setup.

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | lowercase_underscores | `user_profile.ml` |
| Modules | Capitalised_underscores (from the file name) | `User_profile` |
| Primary type | `t` | `type t` |
| Identifiers | `id` | `type id = string` |
| Values | short_descriptive | `find_user`, `create_channel` |

### Labels

Use labels only when they clarify meaning. Avoid `~f` and `~x`.

## Executables

For `bin/` applications:

- Keep argument parsing (cmdliner, Arg) in `bin/`, and the logic in a library so that it can be tested.
- Share the setup (logging, configuration, the main loop of the concurrency library in use) in one module that every command calls, so that all commands run in the same environment.

## Commit Messages

Follow the repository's convention: read `git log` before writing one. Conventional Commits
(`type(scope): subject`, with `feat`, `fix`, `docs`, `refactor`, `test`, `chore`) is one
common convention; many OCaml projects use a plain imperative subject line instead. Do not
switch a repository from one to the other on your own.

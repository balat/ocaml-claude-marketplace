---
name: project-setup
description: "Standards for OCaml project metadata files. Use when initializing a new OCaml library/module, preparing for opam release, setting up CI, discussing project structure, or ensuring proper .mli/.ocamlformat files exist."
---

# OCaml Project Setup

## Required Files

Every OCaml project needs:

| File | Purpose |
|------|---------|
| `dune-project` | Build configuration, opam generation |
| `dune` (root) | Top-level build rules |
| `.ocamlformat` | Code formatting (recommended) |
| `.gitignore` | VCS ignores |
| `LICENSE.md` | License file |
| `README.md` | Project documentation |
| CI config | GitHub Actions, GitLab CI, Tangled, or the host in use |

## Interface Files (.mli)

**Every library module that other code depends on should have an `.mli` file** for:
- Clear API boundaries
- Proper encapsulation
- Documentation surface

```ocaml
(* lib/user.mli *)

(** User accounts.

    A user is identified by an email address, which is unique within a
    workspace. *)

type t
(** The type for users. *)

val create : name:string -> email:string -> t
(** [create ~name ~email] is a new user called [name] with address [email]. *)

val name : t -> string
(** [name u] is the display name of [u]. *)

val pp : Format.formatter -> t -> unit
(** [pp ppf u] formats [u] on [ppf]. *)
```

**Documentation style**: every exported value has a doc comment. The example above uses the
manpage voice (`[f x y] is ...`) described in the `doc-style` skill; the Stdlib style
(imperative sentence, `@param` and `@raise` tags) is the other common choice. Use the one
the project already uses.

## Standard Module Interface

For modules with a central type `t`:

```ocaml
type t
val make : ... -> t                         (* constructor; create, v or of_* as the project names it *)
val of_string : string -> (t, string) result (* constructor that can fail *)
val pp : Format.formatter -> t -> unit      (* pretty-printer *)
val equal : t -> t -> bool                  (* equality *)
val compare : t -> t -> int                 (* comparison *)
```

Add JSON or other conversions with the library the project uses.

## OCamlFormat Configuration

Recommended: a `.ocamlformat` in the project root that pins the version, so that every
contributor formats identically:

```
version = <the version installed>
```

Run `dune fmt` before every commit once the project uses it.

## User Configuration

Read from `~/.claude/ocaml-config.json`:

```json
{
  "author": { "name": "Name", "email": "email@example.com" },
  "license": "ISC",
  "ci_platform": "github",
  "git_hosting": { "type": "github", "org": "username" },
  "ocaml_version": "5.2.0"
}
```

## License

Choose the license explicitly; ask when nothing is configured. Common in the OCaml
ecosystem: ISC, MIT, Apache-2.0, BSD-3-Clause, MPL-2.0, and LGPL-2.1 with the OCaml
linking exception (the license of the compiler and of many older libraries). Templates for
ISC and MIT are provided; copy the text of the others from spdx.org, and the linking
exception from the `LICENSE` file of the OCaml distribution.

If the project puts a license header in every source file, keep it consistent:

```ocaml
(*---------------------------------------------------------------------------
  Copyright (c) {{YEAR}} {{AUTHOR}}. All rights reserved.
  SPDX-License-Identifier: {{LICENSE}}
 ---------------------------------------------------------------------------*)
```

## Project Structure

```
project/
├── dune-project
├── dune
├── .ocamlformat
├── .gitignore
├── LICENSE.md
├── README.md
├── lib/
│   ├── dune
│   ├── foo.ml
│   └── foo.mli         # Interface for every public module
├── bin/
│   ├── dune
│   └── main.ml
├── test/
│   ├── dune
│   ├── test.ml
│   └── test_foo.ml
└── CI configuration    # .github/workflows/, .gitlab-ci.yml or .tangled/workflows/
```

## dune-project

```lisp
(lang dune 3.21)
(name project_name)
(source (github user/project_name))
(license ISC)
(authors "Name <email@example.com>")
(maintainers "Name <email@example.com>")
(generate_opam_files true)

(package
 (name project_name)
 (synopsis "Short description")
 (description "Longer description")
 (depends
  (ocaml (>= 4.14))
  (alcotest (and :with-test (>= 1.7.0)))))
```

**Source options**: `(source (github user/repo))`, `(source (gitlab user/repo))`,
`(source (bitbucket user/repo))`, `(source (tangled handle/repo))` for tangled.org
(`(source (tangled user.domain/project-name))` with a domain handle), or `(source (uri ...))`.

**OCaml version**: declare the oldest version the project supports. 4.14 keeps a library
usable from older switches and js_of_ocaml projects; libraries built on effects (Eio, Miou)
need 5.0 or later.

**Note**: Don't add `(version ...)` - added at release time.

## CI Configuration

`templates/ci-github.yml`, `templates/ci-gitlab.yml` and `templates/ci-tangled.yml` build,
test and generate the documentation. Test on the oldest supported OCaml version as well as
the latest. If the project depends on packages from an extra opam repository, add an
`opam repo add <name> <url>` step before installing dependencies.

### Tangled CI

For projects hosted on tangled.org, create `.tangled/workflows/build.yml`:

```yaml
when:
  - event: ["push", "pull_request"]
    branch: ["main"]

engine: nixery

dependencies:
  nixpkgs:
    - shell
    - stdenv
    - findutils
    - binutils
    - libunwind
    - ncurses
    - opam
    - git
    - gawk
    - gnupatch
    - gnum4
    - gnumake
    - gnutar
    - gnused
    - gnugrep
    - diffutils
    - gzip
    - bzip2
    - gcc
    - ocaml
    - pkg-config

steps:
  - name: opam
    command: |
      opam init --disable-sandboxing -a -y

  - name: deps
    command: |
      opam install . --confirm-level=unsafe-yes --deps-only

  - name: build
    command: |
      opam exec -- dune build

  - name: test
    command: |
      opam install . --confirm-level=unsafe-yes --deps-only --with-test
      opam exec -- dune runtest --verbose
```

| Field | Description |
|-------|-------------|
| `when` | Trigger conditions: `event` (push/pull_request) and `branch` |
| `engine` | Build engine, use `nixery` for Nix-based builds |
| `dependencies.nixpkgs` | List of Nix packages to include |
| `environment` | Global or per-step environment variables |
| `steps` | Build steps with `name` and `command` |

Per-step environment variables:

```yaml
steps:
  - name: test
    environment:
      MY_VAR: value
    command: |
      echo $MY_VAR
```

## Templates

See `templates/` directory for:
- `dune-project.template`
- `dune-root.template`
- `ci-github.yml`
- `ci-gitlab.yml`
- `ci-tangled.yml`
- `gitignore`
- `ocamlformat`
- `LICENSE-ISC.md`
- `LICENSE-MIT.md`
- `README.template.md`

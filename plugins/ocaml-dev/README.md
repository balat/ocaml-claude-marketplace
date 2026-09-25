# OCaml Development Plugin

Comprehensive OCaml development toolkit for Claude Code.

## Features

### Slash Commands

| Command | Description |
|---------|-------------|
| `/init-ocaml [name]` | Initialize a new OCaml project with dune, opam, CI, and standard files |
| `/port-to-dune` | Migrate from ocamlbuild/topkg to dune build system |
| `/add-rfc <number>` | Fetch IETF RFC and add OCamldoc citations |
| `/ocaml-npm` | Set up npm publishing workflow for js_of_ocaml/wasm_of_ocaml |
| `/tidy [path]` | Refactor OCaml code to be more idiomatic and maintainable |

### Skills (Auto-invoked)

#### Project & Build

| Skill | Description |
|-------|-------------|
| project-setup | Project structure, dune-project, .mli files, CI configuration |
| dune-migration | Migrating from ocamlbuild/topkg to dune (_tags, .mllib, pkg.ml) |
| npm-publishing | Publishing to npm via js_of_ocaml and wasm_of_ocaml |
| rfc-integration | Working with IETF RFCs, OCamldoc citations |

#### Code Quality

| Skill | Description |
|-------|-------------|
| ocaml | General OCaml development guidance: interfaces, errors, logging, naming |
| code-style | Refactoring patterns, naming conventions, module hygiene |
| result | Result type patterns and Result.Syntax |
| doc-style | Comment and ocamldoc style in the voice of a POSIX manpage |
| review-ocaml | Two-phase project review: interfaces first, then per-module subagents |
| testing | Testing with Alcotest, Eio mocks, cram tests |
| fuzz | Fuzz testing with Crowbar for parsers and encoders |
| security | Security hardening: integer, buffer and DoS vulnerability classes, CVE regression tests |

#### Documentation

| Skill | Description |
|-------|-------------|
| ocaml-docs | Fixing odoc warnings, reference syntax, cross-package refs |
| tutorials | Creating .mld tutorials with MDX executable examples |

#### Libraries & Frameworks

| Skill | Description |
|-------|-------------|
| eio | Eio concurrency: fibers, switches, mocks, cohttp-eio, bytesrw |
| cmdliner | CLI design with cmdliner following Bünzli's principles |
| jsont | Type-safe JSON encoding/decoding with jsont |
| effects | OCaml 5 algebraic effects design patterns |
| logs | Logging with the Logs library: sources, levels, reporters |
| progress | Terminal progress bars with the progress library |

#### Performance & Advanced

| Skill | Description |
|-------|-------------|
| memtrace | Allocation profiling to identify hotspots |
| oxcaml | OxCaml extensions: modes, stack allocation, unboxed types, SIMD, zero-alloc |

### LSP Integration

Includes ocamllsp configuration for enhanced code intelligence:
- `.ml`, `.mli` - OCaml source and interface
- `.mly`, `.mll` - Menhir grammar, OCamllex lexer
- `.mlx` - OCaml with JSX-like syntax
- `.eliom`, `.eliomi` - Eliom (Ocsigen) source and interface
- `.re`, `.rei` - Reason source and interface

## Configuration

User settings are read from `~/.claude/ocaml-config.json`:

```json
{
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "license": "ISC",
  "copyright_year_start": 2026,
  "ci_platform": "github",
  "git_hosting": {
    "type": "github",
    "org": "username"
  },
  "opam_overlay": {
    "enabled": false,
    "path": null,
    "name": null
  },
  "ocaml_version": "5.2.0"
}
```

### Configuration Options

| Field | Description | Values |
|-------|-------------|--------|
| `license` | Default license for new projects | `ISC`, `MIT`, `Apache-2.0` |
| `ci_platform` | CI system for new projects | `github`, `tangled`, `gitlab` |
| `git_hosting.type` | Git hosting provider | `github`, `tangled`, `gitlab` |
| `ocaml_version` | Minimum OCaml version | e.g., `5.2.0` |

## Usage Examples

### Create a New Project

```
/init-ocaml my-library
```

Creates:
- dune-project with opam generation
- Standard dune files
- .ocamlformat, .gitignore
- LICENSE.md, README.md
- CI configuration
- lib/ and test/ directories

### Migrate from ocamlbuild

```
/port-to-dune
```

Analyzes _tags, .mllib, pkg/pkg.ml and generates dune equivalents.

### Add RFC Documentation

```
/add-rfc 6265
```

Fetches RFC 6265 (HTTP cookies) to spec/, provides OCamldoc citation templates.

### Set Up NPM Publishing

```
/ocaml-npm
```

Creates npm branch workflow for js_of_ocaml/wasm_of_ocaml output.

### Refactor Code

```
/tidy lib/parser.ml
```

Analyzes and suggests idiomatic OCaml improvements.

### Review a Project

```
Review this OCaml project.
```

Invokes `review-ocaml`. Phase one reads only the `dune` and `.mli` files and
reports on the public interfaces, with a restructuring and redocumentation
plan. After you approve it, phase two dispatches a subagent per module to
review the implementation for logic errors, dead code, redundancy and
optimisation opportunities.

## Template Files

Templates are in `skills/*/templates/`:

- CI configurations (GitHub, Tangled, GitLab)
- dune-project and dune file templates
- License files (ISC, MIT)
- Test templates (basic, Eio mock)
- npm publishing templates

## License

ISC License

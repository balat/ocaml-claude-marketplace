# OCaml Claude Marketplace

A collection of Claude Code plugins for OCaml development, based initially on
the experiences in <https://anil.recoil.org/notes/2025-aoah>

## Installation

Add this marketplace to Claude Code:

```
/plugin marketplace add avsm/ocaml-claude-marketplace
```

Then install the OCaml development plugin:

```
/plugin install ocaml-dev@ocaml-claude-marketplace
```

## Available Plugins

### ocaml-dev

Comprehensive OCaml development toolkit including:

**Slash Commands:**
- `/init-ocaml [name]` - Initialize a new OCaml project with dune, opam, CI, and standard files
- `/port-to-dune` - Migrate ocamlbuild/topkg projects to dune
- `/add-rfc <number>` - Fetch an IETF RFC and integrate with ocamldoc citations
- `/ocaml-npm` - Set up npm publishing for js_of_ocaml/wasm_of_ocaml projects
- `/tidy` - Refactor OCaml code to be more idiomatic

**Skills (auto-invoked):**

*Project & Build:*
- **project-setup** - Project structure, dune-project, .mli files, CI configuration
- **dune-migration** - Build system migration (ocamlbuild/topkg to dune)
- **npm-publishing** - npm/browser publishing workflow
- **rfc-integration** - RFC integration and documentation

*Code Quality:*
- **ocaml** - General OCaml development guidance
- **code-style** - Code style and refactoring patterns
- **result** - Result type patterns
- **doc-style** - Comment and ocamldoc style
- **review-ocaml** - Two-phase project review
- **security** - Security hardening and CVE regression tests

*OCaml 5 & Concurrency:*
- **eio** - Eio concurrency patterns, switches, fibers, mocks
- **effects** - Algebraic effects design (effects vs exceptions, layered design)

*Library-Specific:*
- **cmdliner** - CLI design principles and their expression with cmdliner
- **jsont** - Type-safe JSON encoding/decoding with jsont
- **logs** - Logging with the Logs library
- **progress** - Terminal progress bars

*Documentation:*
- **ocaml-docs** - Fixing odoc warnings and reference syntax
- **tutorials** - Tutorial creation with MDX

*Testing & Profiling:*
- **testing** - Testing strategies (Alcotest, ppx_expect, QCheck, cram, Lwt and Eio)
- **fuzz** - Fuzz testing with Crowbar (roundtrips, crash-safety, boundaries)
- **memtrace** - Allocation profiling and hotspot analysis

*OxCaml Extensions:*
- **oxcaml** - Unboxed types, stack allocation, SIMD, zero-alloc annotations

**LSP Integration:**
- ocamllsp for `.ml`, `.mli`, `.mly`, `.mll`, `.mlx`, `.eliom`, `.eliomi`, `.re`, `.rei` files

## User Configuration

Create `~/.claude/ocaml-config.json` for personalized settings:

```json
{
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "license": "ISC",
  "ci_platform": "github",
  "git_hosting": {
    "type": "github",
    "org": "your-username"
  },
  "ocaml_version": "5.2.0"
}
```

If not configured, commands will prompt for required values.

## CI Platform Support

The plugin includes CI templates for:
- GitHub Actions
- Tangled.org
- GitLab CI

Select your preferred platform in the configuration.

## License

ISC License

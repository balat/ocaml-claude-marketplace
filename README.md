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

Comprehensive OCaml development toolkit: five slash commands (`/init-ocaml`, `/port-to-dune`,
`/add-rfc`, `/ocaml-npm`, `/tidy`) and thirty auto-invoked skills covering project setup and
build, code quality and review, documentation, testing and profiling, concurrency (Lwt, Eio,
effects), libraries (cmdliner, jsont, logs, progress), web and mobile applications with
Ocsigen, and OxCaml, plus ocamllsp integration.

The full list, with a description of each skill, is in
[plugins/ocaml-dev/README.md](plugins/ocaml-dev/README.md).

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

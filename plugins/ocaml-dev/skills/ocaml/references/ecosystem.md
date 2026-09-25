# The OCaml library ecosystem, by need

## Contents

- How to weigh a choice
- Concurrency and parallelism
- HTTP, web frameworks, web and mobile applications
- Databases
- Serialisation and data formats
- Parsing and text
- Command lines and terminals
- Cryptography, TLS and hashing
- Time, paths and files
- Standard library extensions and numerics
- Browser, JavaScript and WebAssembly
- Graphical interfaces
- Testing and tooling

## How to weigh a choice

1. Keep what the project already depends on; a switch is a separate decision.
2. Match the concurrency library: HTTP, database and TLS libraries come in Lwt, Eio, Async
   or Miou flavours, and mixing runtimes is a cost.
3. Prefer pure OCaml libraries when the program must run in the browser, on MirageOS, or on
   a machine without the C library; prefer bindings when the C library is the reference
   implementation (OpenSSL, SQLite, GTK).
4. Adoption is visible in the opam repository: `opam list --depends-on <package> --all`
   counts the packages that depend on it. Lwt, cmdliner, fmt, logs, yojson, ppxlib, base,
   re, ppx_deriving, menhir and uri are each used by hundreds of packages; most others by a
   few dozen; a package nobody depends on is not necessarily bad, but check its maintenance.

## Concurrency and parallelism

- **Lwt**: promises and a cooperative event loop. Runs on OCaml 4.14 and 5, native and
  js_of_ocaml. A function that may suspend returns an `'a Lwt.t`, so asynchrony is visible in
  signatures and checked by the compiler, at the price of the monadic style. The largest
  ecosystem: Ocsigen, Dream, cohttp-lwt, MirageOS, Irmin. `lwt_ppx`
  gives `let%lwt`. See the `lwt` skill.
- **Eio**: direct-style I/O on OCaml 5 effects, capability-based, io_uring backend on Linux.
  `eio_main` selects the backend. As with every effect-based library, a function that may
  suspend has an ordinary type: nothing in a signature says which calls block, until OCaml
  has typed effects. See the `eio` skill.
- **Miou**: a small effects-based scheduler for systems programming (Robur).
- **Async**: Jane Street's cooperative library, used with Core.
- **Domainslib**, **Moonpool**: task pools for CPU-bound parallelism on OCaml 5 domains.
- **Saturn**, **Kcas**: lock-free data structures and software transactional memory for
  domains.
- **Lwt_eio**: run Lwt libraries inside an Eio program, or Eio code under Lwt.

## HTTP, web frameworks, web and mobile applications

- **cohttp**: HTTP client and server with Lwt (`cohttp-lwt-unix`), Eio (`cohttp-eio`),
  Async and MirageOS backends; the common base of many tools.
- **httpaf**, **h2**, **httpun**: high-performance HTTP/1.1 and HTTP/2 implementations with
  Lwt, Eio and Async adapters; **Piaf** is an HTTP client built on them.
- **Dream**: a lightweight server-side web framework on Lwt: routes, middleware, sessions,
  templates.
- **Opium**: a Sinatra-like server framework on Lwt.
- **Ocsigen Server** and **Eliom**: an HTTP server with an extension mechanism, and a full
  web framework on top of it: typed services and parameters, links and forms checked at
  compile time, scoped sessions, continuation-based services, and the multi-tier model in
  which server and client are one OCaml program compiled to JavaScript or WebAssembly, with
  a Cordova build for mobile. **Ocsigen Start** adds users and sessions, **Ocsigen Toolkit**
  widgets, **TyXML** typed HTML. See the `ocsigen-overview` skill.
- **TyXML** is usable with any server: typed HTML and SVG as OCaml values.

## Databases

SQL drivers:

- **caqti**: one interface over PostgreSQL, SQLite and MariaDB drivers, with Lwt, Eio,
  Async and Miou variants; **ppx_rapper** adds typed queries on top of it.
- **pgocaml**: PostgreSQL client with `pgocaml_ppx`, which checks each query against the
  live database at build time and types its parameters and results; used by Ocsigen Start.
- **postgresql**: bindings to libpq. **pgx**: a pure OCaml PostgreSQL client, with Lwt and
  Async variants. **postgres_async**: Jane Street's pure implementation for Async.
- **sqlite3**: bindings to SQLite; **ezsqlite** simplifies them.
- **mariadb**, **mysql**: bindings to the MariaDB and MySQL client libraries.

Key-value, document and versioned stores:

- **Irmin**: a distributed, versioned store with Git-like semantics (branches, merges,
  history), several backends (memory, file system, Git repositories, pack files) and
  GraphQL or HTTP servers; the store of Tezos and of many MirageOS unikernels.
- **ocsipersist**: persistent key-value storage with SQLite, PostgreSQL or DBM backends,
  used by Eliom for persistent references and by Ocsigen Start.
- **lmdb**, **leveldb**: bindings to embedded key-value databases.
- **redis**: a Redis client with Lwt, Async and synchronous variants; **hiredis** binds the
  C library.

## Serialisation and data formats

- JSON: **yojson** (the most widespread, with **ppx_deriving_yojson** or
  **ppx_yojson_conv** for derived codecs), **jsont** (typed bidirectional codecs, see the
  `jsont` skill), **ezjsonm** (simple values), **jsonm** (streaming), **atdgen** (codecs
  generated from one schema for OCaml and other languages), **decoders** (combinators over
  several JSON libraries).
- YAML: **yaml**. TOML: **otoml**, **toml**.
- XML: **xmlm** (streaming), **xml-light** (tree), **markup** (HTML5 and XML, streaming).
- S-expressions: **sexplib** with **ppx_sexp_conv**, **csexp** (canonical S-expressions,
  used by dune).
- Binary: **bin_prot** (Jane Street), **cbor**, **msgpck**, **data-encoding** (Tezos).
- Protobuf and gRPC: **ocaml-protoc** and **ocaml-protoc-plugin**, **grpc** with Lwt, Eio
  and Async adapters.
- CSV: **csv**.

## Parsing and text

- Grammars: **menhir** (LR parsers) with **ocamllex** (in the distribution) or **sedlex**
  (Unicode-aware lexers).
- Combinators: **angstrom** (fast, binary and text, Lwt or Async adapters), **mparser**.
- Regular expressions: **re** (pure OCaml, several syntaxes), **Str** (Stdlib, global
  state, not thread-safe), **re2** (bindings).
- Unicode: **uutf**, **uucp**, **uunf**, **uuseg**, **camomile**.
- URIs: **uri**.

## Command lines and terminals

- **cmdliner**: terms, subcommands, generated man pages (see the `cmdliner` skill).
- **Arg**: in the Stdlib, enough for a few flags. **Clap**, **minicli**: lighter parsers.
- **notty**, **lambda-term**: terminal user interfaces; **progress**: progress bars
  (see the `progress` skill); **ANSITerminal**: colours.

## Cryptography, TLS and hashing

- **mirage-crypto** (ciphers, RNG, public-key), **tls** (a pure OCaml TLS stack with Lwt,
  Eio, Miou, Async and MirageOS variants), **x509**, **ca-certs**: no C dependency.
- **ssl**: bindings to OpenSSL; **cryptokit**: a classic C-backed library.
- **digestif**: hashes (SHA, BLAKE2, MD5) in C or pure OCaml.
- Passwords: **argon2** (bindings), **safepass** (bcrypt).

## Time, paths and files

- **ptime** (POSIX time, no dependency), **mtime** (monotonic clocks), **calendar** and
  **timedesc** (calendars, time zones, durations).
- **fpath** (typed file paths), **bos** (basic OS interaction: files, directories,
  commands), **fileutils**, **directories** and **xdg** (standard directories).
- **Unix** (in the distribution) for system calls; **lwt.unix** and **eio_main** for their
  cooperative counterparts.

## Standard library extensions and numerics

- **containers**: extends the Stdlib modules and adds data structures without replacing
  the Stdlib.
- **base** and **core** (Jane Street): a replacement Stdlib with its own conventions,
  **ppx_jane** derivers, **core_unix**; **async** and **bin_prot** belong to the same family.
- **batteries**: an older extended Stdlib. **stdcompat**: Stdlib functions backported to
  old compilers. **astring**: string functions in the erratique style.
- **zarith** (arbitrary-precision integers), **owl** (scientific computing), **lacaml**
  (BLAS and LAPACK).

## Browser, JavaScript and WebAssembly

- **js_of_ocaml**: compiles OCaml bytecode to JavaScript; **wasm_of_ocaml** to
  WebAssembly. Any OCaml library works; `js_of_ocaml-ppx` gives the `##` object syntax,
  `js_of_ocaml-lwt` the DOM event loops, `js_of_ocaml-tyxml` typed DOM nodes.
- Bindings: the **Js_of_ocaml** modules (`Js`, `Dom_html`), **brr** (a different,
  erratique-style binding of the browser APIs), **gen_js_api** (bindings generated from
  `.mli` files).
- **melange**: compiles OCaml to JavaScript with a separate toolchain oriented towards the
  JavaScript ecosystem (React, npm).
- **Eliom** builds on js_of_ocaml for client-server applications.

## Graphical interfaces

- **lablgtk3**: GTK 3 bindings. **bogue**: a pure OCaml toolkit on SDL. **tsdl**: SDL 2
  bindings. **raylib**: raylib bindings. **lablqml**: Qt Quick.

## Testing and tooling

- Tests: **alcotest**, **ounit2**, **ppx_expect** and **ppx_inline_test**, **qcheck**,
  **crowbar**, cram tests (dune); **bisect_ppx** for coverage (see the `testing` and
  `fuzz` skills).
- Tooling: **dune**, **opam**, **ocamlformat**, **odoc**, **merlin** and **ocaml-lsp-server**,
  **utop**, **mdx** (executable documentation), **dune-release** and **opam-publish** for
  releases.
- ppx: **ppxlib** is the base of every rewriter; **ppx_deriving** (show, eq, ord, ...),
  **ppx_sexp_conv**, **ppx_yojson_conv**, **ppx_deriving_yojson**, `lwt_ppx`.

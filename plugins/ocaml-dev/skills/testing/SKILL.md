---
name: testing
description: Testing strategies for OCaml libraries and executables. Use when discussing tests, alcotest, ppx_expect, QCheck, cram tests, testing Lwt or Eio code, test structure, or test-driven development in OCaml projects.
---

# OCaml Testing

## Frameworks

Follow the framework the project already uses. For a new project, the common options:

| Framework | Style | Good for |
|-----------|-------|----------|
| Alcotest | unit tests grouped in suites, readable output | most libraries and executables |
| OUnit2 | xUnit style | code bases that already use it |
| ppx_expect and ppx_inline_test | tests next to the code, expected output blocks promoted with `dune promote` | values with printers, parsers, formatters |
| QCheck (with qcheck-alcotest) | property-based tests | invariants, roundtrips, laws |
| Crowbar | fuzzing | parsers and decoders (see the `fuzz` skill) |
| cram (dune `cram` stanza) | end-to-end runs of an executable | command-line tools |

The rest of this skill shows Alcotest, with the additions needed for Lwt and Eio code.

## Test Directory Structure

Use `test/` directory with:
- `test.ml` - Main runner controlling initialization order
- `test_x.ml` - One file per module `x.ml` being tested, exports `suite`

```
lib/
├── foo.ml
└── bar.ml
test/
├── dune
├── test.ml          # Main runner
├── test_foo.ml      # suite : (string * unit Alcotest.test_case list) list
└── test_bar.ml
```

For single-module libraries, a single `test_foo.ml` as runner is acceptable
(`templates/test_template.ml`).

## Dune Configuration

```dune
(test
 (name test)
 (libraries mylib alcotest))
```

Add `alcotest-lwt lwt.unix` for Lwt code, `eio_main eio.mock` for Eio code, and
`(preprocess (pps lwt_ppx))` if the tests use `let%lwt`.

## Main Runner Pattern (test.ml)

```ocaml
let () = Alcotest.run "mylib" (Test_foo.suite @ Test_bar.suite)
```

If the library needs global initialization (a random number generator, a logging reporter,
temporary directories), do it in `test.ml` before `Alcotest.run` and nowhere else: test
modules must be loadable in any order and must not run tests at load time.

## Module Test File Pattern (test_x.ml)

Each module exports a `suite` value. **Do not initialize global state or run Alcotest here.**

```ocaml
(** Tests for Foo module. *)

let test_basic () =
  let result = Foo.process "input" in
  Alcotest.(check string) "expected output" "output" result

let test_empty () =
  let result = Foo.process "" in
  Alcotest.(check string) "empty input" "" result

let suite =
  [
    ( "process",
      [
        Alcotest.test_case "basic" `Quick test_basic;
        Alcotest.test_case "empty" `Quick test_empty;
      ] );
  ]
```

## Lazy State for Module-Level Values

If a test module needs initialized state at load time, use lazy evaluation:

```ocaml
let key = lazy (Random_source.generate 32)
let key () = Lazy.force key

let test_encrypt () =
  let ciphertext = Foo.encrypt ~key:(key ()) plaintext in
  ...
```

This defers the use until tests actually run, after `test.ml` has initialized everything.

## Alcotest Patterns

### Custom Testables

```ocaml
let result_testable ok_t =
  Alcotest.result ok_t Alcotest.string

let my_type_testable =
  Alcotest.testable My_type.pp My_type.equal
```

### Common Checks

```ocaml
Alcotest.(check int) "count" 42 actual
Alcotest.(check string) "name" expected actual
Alcotest.(check bool) "flag" true actual
Alcotest.(check (list int)) "items" [1;2;3] actual
Alcotest.(check (option string)) "maybe" (Some "x") actual
Alcotest.(check (result int string)) "result" (Ok 42) actual
```

### Testing Exceptions

```ocaml
let test_raises () =
  Alcotest.check_raises "should fail" (Invalid_argument "bad")
    (fun () -> Foo.parse "bad")
```

## Testing Lwt Code

With `alcotest-lwt`, a test case is a function returning a promise; the runner drives the
event loop:

```ocaml
(* test/dune: (libraries mylib alcotest alcotest-lwt lwt.unix) *)
let test_fetch _switch () =
  let open Lwt.Syntax in
  let* body = Client.fetch "resource" in
  Alcotest.(check string) "body" "ok" body;
  Lwt.return_unit

let suite = [ ("client", [ Alcotest_lwt.test_case "fetch" `Quick test_fetch ]) ]

let () = Lwt_main.run (Alcotest_lwt.run "mylib" suite)
```

Without `alcotest-lwt`, wrap each test body in `Lwt_main.run`. Replace real delays by
`Lwt_unix.sleep` with small durations or by a fake clock passed to the code under test.
`templates/test_lwt.ml` is a starting point; the `lwt` skill covers the library.

## Testing Eio Code

Prefer the mock backend for deterministic, fast tests:

```ocaml
(* test/dune: (libraries mylib alcotest eio_main eio.mock) *)
let test_with_mock_clock () =
  Eio_mock.Backend.run @@ fun () ->
  let clock = Eio_mock.Clock.make () in
  Eio_mock.Clock.advance clock 1.0;
  Alcotest.(check bool) "advanced" true true

let test_with_mock_flow () =
  Eio_mock.Backend.run @@ fun () ->
  let flow = Eio_mock.Flow.make "test" in
  Eio_mock.Flow.on_read flow [ `Return "data"; `Raise End_of_file ];
  (* test with flow *)
```

Mock modules: `Eio_mock.Backend`, `Eio_mock.Clock`, `Eio_mock.Flow`, `Eio_mock.Net`,
`Eio_mock.Fs`. `templates/test_eio_mock.ml` is a starting point; the `eio` skill covers
the library.

## Expect Tests (ppx_expect)

```dune
(library
 (name mylib_test)
 (inline_tests)
 (preprocess (pps ppx_expect)))
```

```ocaml
let%expect_test "render" =
  print_string (Render.to_string example);
  [%expect {| <p>hello</p> |}]
```

`dune runtest` shows a diff against the expected block; `dune promote` accepts the new
output. Expect tests suit anything with a printer: parsers, pretty-printers, error messages.

## Property-Based Testing (QCheck)

For complex logic, consider property-based testing:

```ocaml
let test_roundtrip =
  QCheck.Test.make ~count:1000
    ~name:"encode then decode is identity"
    QCheck.string
    (fun s -> Codec.decode (Codec.encode s) = s)
```

`qcheck-alcotest` turns such tests into Alcotest cases.

## End-to-End Testing with Cram

Cram tests verify CLI executable behavior.

**Use Cram Directories**: Every Cram test should be a directory ending in `.t` (e.g., `my_feature.t/`).

**Create Actual Test Files**: Avoid embedding code within `run.t` using heredocs. Create real source files within the test directory.

```
test/
└── my_feature.t/
    ├── run.t           # The cram test script
    ├── input.txt       # Test input file
    └── expected.json   # Expected output
```

## Core Philosophy

1. **Unit Tests First**: Prioritize unit tests for individual modules and functions.
2. **Coverage of the interface**: Every module with a public `.mli` has a test module exercising it.
3. **Isolated Tests**: Each test should be independent and not rely on external state.
4. **Clear Test Names**: Test names should describe what they test, not how.
5. **Test Inclusion**: All test suites must be included in the main test runner.

## Naming Conventions

- **Test suite names**: lowercase, single words (e.g., `"users"`, `"commands"`, `"process"`)
- **Test case names**: lowercase with underscores, concise but descriptive (e.g., `"basic"`, `"empty_input"`, `"parse_error"`)

## Writing Good Tests

**Function Coverage**: Test all public functions exposed in `.mli` files, including success, error, and edge cases.

**Test Data**: Use helper functions to create test data:

```ocaml
let make_user ?(name = "test") ?(id = 1) () = User.make ~name ~id
```

## Running Tests

```bash
# Run all tests
dune test

# Run tests and watch for changes
dune test -w

# Run a specific test
dune exec test/test.exe -- test "suite_name"

# Run tests with coverage
dune test --instrument-with bisect_ppx
bisect-ppx-report summary
```

## Templates

- `templates/test_template.ml` - single-file Alcotest runner for a small library
- `templates/test_lwt.ml` - alcotest-lwt runner
- `templates/test_eio_mock.ml` - Eio mock-based tests

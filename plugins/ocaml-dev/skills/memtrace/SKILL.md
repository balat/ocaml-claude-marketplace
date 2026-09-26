---
name: memtrace
description: "OCaml memtrace profiling for allocation hotspot analysis. Use when Claude needs to: (1) Add memtrace instrumentation to OCaml executables, (2) Run targeted benchmarks with tracing enabled, (3) Identify allocation hotspots from trace output, (4) Optimize code to reduce boxing and allocations, (5) Validate optimizations with before/after comparisons"
---

# Allocation Profiling with memtrace

memtrace records a statistical sample of allocations of an OCaml program and lets a viewer
attribute them to call sites. Use it to instrument code, capture traces, identify allocation
hotspots and validate optimisations. Keep tracing gated behind the MEMTRACE environment
variable, target specific tests or benchmarks to isolate hotspots, and focus on actionable
insight: which functions allocate, why, and how to fix it. OCaml boxes int32, int64 and
floats stored in polymorphic containers; int is unboxed.

## When to use

Use this skill when:
- Investigating why a function allocates more than expected
- Identifying boxing overhead (int32, int64, floats in arrays)
- Optimizing hot paths in parsing/serialization code
- Comparing allocation behavior before and after changes

Do **not** use this skill for:
- Exact allocation counting (memtrace is statistical)
- Performance timing (use `Sys.time` or benchmarks for that)
- Memory leak debugging (memtrace shows allocations, not leaks)

---

### Instrumentation pattern

Add to the main entrypoint, before any work begins:

```ocaml
let () =
  Memtrace.trace_if_requested ();
  (* rest of program *)
```

For Alcotest test suites:

```ocaml
(* test/test.ml *)
let () =
  Memtrace.trace_if_requested ();
  Alcotest.run "suite-name" [
    Test_foo.suite;
    Test_bar.suite;
  ]
```

Rules:
- Call once, at program start
- No `~context` argument needed for simple cases
- Never enable tracing unconditionally

---

### Build configuration

Add memtrace to the test executable in dune:

```lisp
(test
 (name test)
 (libraries memtrace alcotest ...))
```

Or for a standalone executable:

```lisp
(executable
 (name main)
 (libraries memtrace ...))
```

---

### Running with memtrace

Basic usage:

```bash
MEMTRACE=trace.ctf dune exec -- path/to/exe
```

For Alcotest, target a specific test to isolate allocations:

```bash
# Run specific test suite
MEMTRACE=trace.ctf dune exec -- test/test.exe test "binary"

# Run specific test by index within suite
MEMTRACE=trace.ctf dune exec -- test/test.exe test "binary" 68

# List available tests first
dune exec -- test/test.exe test list
```

The trace file (`.ctf`) is binary but contains embedded strings showing:
- Source file paths and line numbers
- Function names and call stacks
- Allocation counts and sizes

---

### Analyzing traces

**With memtrace-viewer (GUI):**

```bash
memtrace-viewer trace.ctf
# Opens browser at http://localhost:8080
```

**With memtrace-hotspot (CLI):**

```bash
opam install memtrace-hotspot
memtrace-hotspot trace.ctf
```

**Reading raw trace output:**

The MEMTRACE environment produces summary output showing:
- Total allocations in bytes
- Top allocation sites by percentage
- Call stacks leading to allocations

Example output:
```
76.3 MB total allocations
  30.2% lib/binary.ml:194 Bytes.get_int32_be
  15.1% lib/binary.ml:210 Bytes.get_int64_be
  ...
```

---

### Common hotspots and fixes

**1. Int32/Int64 boxing**

Problem: `Bytes.get_int32_be` returns `int32` which is always boxed.

```ocaml
(* SLOW: boxes on every call *)
let v = Bytes.get_int32_be buf off
```

Fix: Read bytes individually, box only at the end:

```ocaml
(* FAST: single box at the end *)
let read_uint32_be buf off =
  let b0 = Bytes.get_uint8 buf off in
  let b1 = Bytes.get_uint8 buf (off + 1) in
  let b2 = Bytes.get_uint8 buf (off + 2) in
  let b3 = Bytes.get_uint8 buf (off + 3) in
  Int32.of_int ((b0 lsl 24) lor (b1 lsl 16) lor (b2 lsl 8) lor b3)
```

**2. Closure allocation in loops**

Problem: a partial application or a `let*` inside a loop body allocates a closure on every
iteration. (A closure passed once to `List.iter` is allocated once, not per element.)

```ocaml
(* Slow: a new closure per element *)
List.iter (fun x -> let f = process key in f x) items
```

Fix: Inline or use direct recursion:

```ocaml
(* Fast: the partial application is hoisted, or the loop is written directly *)
let rec loop = function
  | [] -> ()
  | x :: xs -> process key x; loop xs
in loop items
```

**3. Array bounds checking**

For proven-safe indices, use unsafe access:

```ocaml
(* Lookup table - indices always valid *)
Array.unsafe_get table ((byte lsr 4) land 0xF)
```

---

### Optimization workflow

1. **Baseline**: Run benchmark with memtrace, note total allocations
2. **Identify**: Find top allocation sites (>10% of total)
3. **Analyze**: Determine if allocations are necessary or avoidable
4. **Fix**: Apply targeted optimizations (see common fixes above)
5. **Validate**: Re-run with memtrace, compare totals

Example of a report:
- Before: 76.3 MB total, 30% from one boxed-integer accessor
- After: 53.4 MB total once the accessor reads bytes directly
- Reduction: 30%

---

### Considerations for int32/int64 APIs

If your API returns `int32` or `int64`, boxing is unavoidable at the boundary.
Consider:

- **Optint.Int63.t**: Unboxed on 64-bit platforms, fits in native int
- **Returning int**: If values fit in 31/63 bits, avoid boxed types entirely
- **Streaming APIs**: Process data without intermediate boxed values

Check what other libraries do:
- `bytesrw`: Uses `int` where possible, `int64` only when necessary

---

### Expected outputs

When this skill is invoked, produce:

1. Instrumentation patch (single `Memtrace.trace_if_requested ()` call)
2. Dune changes if memtrace not already linked
3. Exact command to run targeted benchmark with tracing
4. Analysis of trace output identifying top hotspots
5. Concrete code changes to reduce allocations
6. Before/after comparison showing improvement

---

### Avoiding common mistakes

- **Wrong process**: Trace the worker, not the test harness
- **Too broad**: Target specific tests, not entire suites
- **Comparing apples to oranges**: Same workload, same sampling rate
- **Premature optimization**: Focus on hotspots >10% of allocations
- **Breaking APIs**: Don't change public signatures just to avoid boxing

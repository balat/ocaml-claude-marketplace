(*---------------------------------------------------------------------------
  Copyright (c) {{YEAR}} {{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}>. All rights reserved.
  SPDX-License-Identifier: {{LICENSE}}
 ---------------------------------------------------------------------------*)

(** Lwt tests for {{PROJECT_NAME}}, run with alcotest-lwt.
    test/dune: (test (name test) (libraries {{PROJECT_NAME}} alcotest alcotest-lwt lwt.unix)) *)

open Lwt.Syntax

let test_immediate _switch () =
  let* v = Lwt.return 42 in
  Alcotest.(check int) "immediate promise" 42 v;
  Lwt.return_unit

let test_sleep _switch () =
  let* () = Lwt_unix.sleep 0.01 in
  Alcotest.(check bool) "resumed after sleep" true true;
  Lwt.return_unit

let test_both _switch () =
  let* a, b = Lwt.both (Lwt.return 1) (Lwt.return 2) in
  Alcotest.(check int) "sum of concurrent promises" 3 (a + b);
  Lwt.return_unit

let suite =
  [
    ( "lwt",
      [
        Alcotest_lwt.test_case "immediate" `Quick test_immediate;
        Alcotest_lwt.test_case "sleep" `Quick test_sleep;
        Alcotest_lwt.test_case "both" `Quick test_both;
      ] );
  ]

let () = Lwt_main.run (Alcotest_lwt.run "{{PROJECT_NAME}}" suite)

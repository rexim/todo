open OUnit2

let suite =
  "suite" >:::
    [ (* "label" >:: test_function *) ]

let () = run_test_tt_main suite

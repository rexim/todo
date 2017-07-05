open OUnit2

let suite =
  "suite" >:::
    ["TodoStream.flatten" >:: TodoStreamTest.flatten]

let () = run_test_tt_main suite

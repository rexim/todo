open OUnit2

let suite =
  "suite" >:::
    ["TodoStream.flatten" >:: TodoStreamTest.flatten;
     "TodoStream.map" >:: TodoStreamTest.map]

let () = run_test_tt_main suite

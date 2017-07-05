open OUnit2
open TodoStream

let test_todo_stream_flatten test_ctxt =
  skip_if true "Not implemented yet";
  assert_equal (let accum = ref [] in
                begin
                  Stream.of_list [Stream.of_list [1; 2; 3];
                                  Stream.of_list [1; 2; 3];
                                  Stream.of_list [1; 2; 3]]
                  |> TodoStream.flatten
                  |> Stream.iter (fun x -> accum := x :: !accum);
                  List.rev !accum
                end)
               [1; 2; 3;
                1; 2; 3;
                1; 2; 3]

let suite =
  "suite">:::
    ["test_todo_stream_flatten" >:: test_todo_stream_flatten]


let () = run_test_tt_main suite

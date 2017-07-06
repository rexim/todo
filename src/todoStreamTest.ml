open OUnit2
open TodoStream

let flatten test_ctxt =
  skip_if true "Not implemented yet";
  assert_equal [1; 2; 3;
                1; 2; 3;
                1; 2; 3]
               (let accum = ref [] in
                begin
                  Stream.of_list [Stream.of_list [1; 2; 3];
                                  Stream.of_list [1; 2; 3];
                                  Stream.of_list [1; 2; 3]]
                  |> TodoStream.flatten
                  |> Stream.iter (fun x -> accum := x :: !accum);
                  List.rev !accum
                end)
               ~printer: (TodoList.string_of_list string_of_int)

let map test_ctxt =
  assert_equal [2; 4; 6]
               (let accum = ref [] in
                begin
                  [1; 2; 3]
                  |> Stream.of_list
                  |> TodoStream.map (fun x -> x * 2)
                  |> Stream.iter (fun x -> accum := x :: !accum);
                  List.rev !accum
                end)
               ~printer: (TodoList.string_of_list string_of_int)

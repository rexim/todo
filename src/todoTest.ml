open Batteries
open OUnit2
open TodoFile

let suite =
  "suite" >:::
    [ (* "label" >:: test_function *)
      "replace_line_at_location" >::
        (fun test_ctxt ->
          let file = Filename.temp_file "todo" "txt" in
          [ "foo"; "bar"; "baz" ]
          |> List.enum
          |> TodoFile.stream_to_file file;
          TodoFile.replace_line_at_location { file_path = file
                                            ; line_number = 1 }
                                            "hello";
          (* TODO: assert_equal does not print the values it compares *)
          assert_equal [ "foo"; "hello"; "baz" ]
                       (TodoFile.stream_of_lines file
                        |> List.of_enum)) ]

let () = run_test_tt_main suite

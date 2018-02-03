open Batteries
open OUnit2
open TodoFile
open Todo

let suite =
  "suite" >:::
    [ (* "label" >:: test_function *)
      "TodoFile.replace_line_at_location" >::
        (fun test_ctxt ->
          let file = Filename.temp_file "todo" "txt" in
          [ "foo"; "bar"; "baz" ]
          |> List.enum
          |> TodoFile.stream_to_file file;
          TodoFile.replace_line_at_location { file_path = file
                                            ; line_number = 1 }
                                            "hello";
          (* TODO(#47): assert_equal does not print the values it compares *)
          assert_equal [ "foo"; "hello"; "baz" ]
                       (TodoFile.stream_of_lines file
                        |> List.of_enum))
    ; "Todo.todos_of_file" >::
        (fun test_ctxt ->
          let file = Filename.temp_file "todo" "txt" in
          [ "hello"
          ; "TODO: world"
          ; "TODO: foo" ]
          |> List.enum
          |> TodoFile.stream_to_file file;
          assert_equal [ Some 1; Some 2 ]
                       (Todo.todos_of_file file
                        |> Enum.map (fun todo ->
                               todo.location
                               |> BatOption.map (fun l -> l.line_number))
                        |> List.of_enum
                        |> List.sort compare))
    ]

let () = run_test_tt_main suite

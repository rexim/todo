type file_location =
  {
    file_path : string;
    line_number : int;
  }

type todo =
  {
    id : string option;
    title : string;
    location : file_location option;
  }

let empty_todo =
  {
    id = None;
    title = "";
    location = None
  }

let regexp_matched_todo line regexp todo_from_groups =
  if Str.string_match regexp line 0
  then Some (todo_from_groups ())
  else None

let line_as_todo_with_id line =
  regexp_matched_todo
    line
    (Str.regexp "^.*TODO(\\(.*\\)) *: *\\(.*\\)$")
    (fun () -> { empty_todo with
                 id = Some((Str.matched_group 1 line));
                 title = Str.matched_group 2 line })

let line_as_todo_without_id line =
  regexp_matched_todo
    line
    (Str.regexp "^.*TODO *: *\\(.*\\)$")
    (fun () -> { empty_todo with
                 title = Str.matched_group 1 line })

(* TODO: make todo tool commentaries aware *)
let line_as_todo line =
  TodoOption.first_some (line_as_todo_with_id line)
                        (line_as_todo_without_id line)

let located_todo location todo =
  { todo with location = Some location }

let todos_of_file file_path: todo Stream.t =
  file_path
  |> TodoFile.stream_of_lines
  |> TodoStream.indexed
  |> TodoStream.collect (fun (index, line) ->
         line_as_todo line
         |> TodoOption.map (located_todo { file_path = file_path;
                                           line_number = index + 1 }))

let usage () =
  print_endline "Usage: todo <files..>"

let file_location_as_string location =
  Printf.sprintf "%s:%d" location.file_path location.line_number

let todo_as_string todo =
  Printf.sprintf "%s: %s"
                 (todo.location
                  |> TodoOption.map file_location_as_string
                  |> TodoOption.default "<none>")
                 todo.title

let find_todo_by_id search_id todos =
  todos
  |> TodoStream.find (fun todo ->
       todo.id
       |> TodoOption.flat_map (fun id ->
              if search_id == id
              then Some id
              else None)
       |> TodoOption.is_some)


let todos_of_dir_path dir_path: todo Stream.t =
  dir_path
  |> TodoFile.file_stream_of_dir_tree
  |> TodoStream.map todos_of_file
  |> TodoStream.flatten

let _ =
  match Sys.argv |> Array.to_list with
  | [] -> usage ()
  | [_] -> usage ()
  | _ :: id :: _ -> let current_dir = Sys.getcwd () in
                    current_dir
                    |> TodoFile.root_of_git_repo
                    |> TodoOption.default current_dir
                    |> todos_of_dir_path
                    |> find_todo_by_id id
                    |> TodoOption.map todo_as_string
                    |> TodoOption.default "Nothing"
                    |> print_endline

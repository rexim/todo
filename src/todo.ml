type todo =
  {
    id : string option;
    title : string;
    location : TodoFile.location_t option;
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
         |> TodoOption.map (TodoFile.location file_path (index + 1)
                            |> located_todo))

let usage () =
  print_endline "Usage: todo [<id> --] [register --] <files...>"

let todo_as_string todo =
  Printf.sprintf "%s: %s"
                 (todo.location
                  |> TodoOption.map TodoFile.location_as_string
                  |> TodoOption.default "<none>")
                 todo.title

let find_todo_by_id search_id todos =
  todos
  |> TodoStream.find (fun todo ->
       todo.id
       |> TodoOption.flat_map (fun id ->
              id
              |> String.equal search_id
              |> TodoOption.of_bool id)
       |> TodoOption.is_some)


let todos_of_dir_path dir_path: todo Stream.t =
  dir_path
  |> TodoFile.file_stream_of_dir_tree
  |> TodoStream.map todos_of_file
  |> TodoStream.flatten

let todos_of_file_list files =
  files
  |> Stream.of_list
  |> TodoStream.map todos_of_file
  |> TodoStream.flatten

let is_todo_unregistered (todo: todo): bool =
  match todo.id with
  | Some _ -> false
  | None -> true

let register_todo (todo: todo): todo =
  { todo with id = Some (Uuidm.create `V4 |> Uuidm.to_string) }

(* TODO(#28): Implement todo_as_line *)
let todo_as_line (todo: todo): string =
  failwith "Unimplemented"

let persist_todo (todo: todo): unit =
  todo.location
  |> TodoOption.iter (fun location ->
       todo
       |> todo_as_line
       |> TodoFile.replace_line_at_location location)

let _ =
  match Sys.argv |> Array.to_list with
  | _ :: "register" :: "--" :: files ->
     files
     |> todos_of_file_list
     |> TodoStream.filter is_todo_unregistered
     |> TodoStream.map register_todo
     |> TodoStream.map persist_todo
     |> TodoStream.as_list
     |> List.length
     |> Printf.sprintf "Registred %d TODOs"
     |> print_endline
  | _ :: id :: "--" :: files ->
     files
     |> todos_of_file_list
     |> find_todo_by_id id
     |> TodoOption.map todo_as_string
     |> TodoOption.default "Nothing"
     |> print_endline
  | _ :: files when List.length files != 0  ->
     files
     |> todos_of_file_list
     |> TodoStream.map todo_as_string
     |> Stream.iter print_endline
  | _ -> usage ()

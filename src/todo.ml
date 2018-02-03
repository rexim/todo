open Batteries
open BatOption.Infix

type todo =
  {
    id : string option;
    prefix: string;
    suffix: string;
    location : TodoFile.location_t option;
  }

let empty_todo =
  {
    id = None;
    prefix = "";
    suffix = "";
    location = None
  }

let regexp_matched_todo line regexp todo_from_groups =
  if Str.string_match regexp line 0
  then Some (todo_from_groups ())
  else None

let line_as_todo_with_id line =
  regexp_matched_todo
    line
    (Str.regexp "\\(^.*\\)TODO(\\(.*\\)) *: *\\(.*\\)$")
    (fun () -> { empty_todo with
                 prefix = Str.matched_group 1 line;
                 id = Some((Str.matched_group 2 line));
                 suffix = Str.matched_group 3 line })

let line_as_todo_without_id line: todo option =
  regexp_matched_todo
    line
    (Str.regexp "\\(^.*\\)TODO *: *\\(.*\\)$")
    (fun () -> { empty_todo with
                 prefix = Str.matched_group 1 line;
                 suffix = Str.matched_group 2 line })

(* TODO(#6): make todo tool commentaries aware *)
let line_as_todo line =
  (line_as_todo_with_id line)
  |> BatOption.map BatOption.some
  |> BatOption.default (line_as_todo_without_id line)

let located_todo location todo =
  { todo with location = Some location }

let todos_of_file file_path: todo Enum.t =
  file_path
  |> TodoFile.stream_of_lines
  |> Enum.mapi (fun index line -> (index, line))
  |> Enum.filter_map (fun (index, line) ->
         line_as_todo line
         |> BatOption.map (TodoFile.location file_path index
                           |> located_todo))

let usage () =
  print_endline "Usage: todo [<id> --] [register --] <files...>"

let find_todo_by_id search_id todos =
  try
    todos
    |> Enum.find (fun todo ->
           todo.id >>= (fun id -> if String.equal search_id id
                                  then Some id
                                  else None)
           |> BatOption.is_some)
    |> BatOption.some
  with
    Not_found -> None


let todos_of_dir_path dir_path: todo Enum.t =
  dir_path
  |> TodoFile.file_stream_of_dir_tree
  |> Enum.map todos_of_file
  |> Enum.flatten

let todos_of_file_list files =
  files
  |> List.enum
  |> Enum.map todos_of_file
  |> Enum.flatten

let is_todo_unregistered (todo: todo): bool =
  match todo.id with
  | Some _ -> false
  | None -> true

let register_todo (todo: todo): todo =
  { todo with id = Some (Uuidm.create `V4 |> Uuidm.to_string) }

(* TODO(#44): implement mechanism for ignoring false detected TODO lines *)
let todo_as_line (todo: todo): string =
  match todo.id with
  | Some id -> Printf.sprintf "%sTODO(%s): %s" todo.prefix id todo.suffix
  | None -> Printf.sprintf "%sTODO: %s" todo.prefix todo.suffix

let persist_todo (todo: todo): unit =
  todo.location
  |> BatOption.may (fun location ->
       todo
       |> todo_as_line
       |> TodoFile.replace_line_at_location location)

let _ =
  match Sys.argv |> Array.to_list with
  | _ :: "register" :: "--" :: files ->
     files
     |> todos_of_file_list
     |> Enum.filter is_todo_unregistered
     |> Enum.map register_todo
     |> Enum.map persist_todo
     |> List.of_enum
     |> List.length
     |> Printf.sprintf "Registred %d TODOs"
     |> print_endline
  | _ :: id :: "--" :: files ->
     files
     |> todos_of_file_list
     |> find_todo_by_id id
     |> BatOption.map todo_as_line
     |> BatOption.default "Nothing"
     |> print_endline
  | _ :: files when List.length files != 0  ->
     files
     |> todos_of_file_list
     |> Enum.map todo_as_line
     |> Enum.iter print_endline
  | _ -> usage ()

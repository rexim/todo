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

let stream_as_list stream =
  let result = ref [] in
  begin
    Stream.iter (fun x -> result := x :: !result) stream;
    List.rev !result
  end

let rec files_of_repo path =
  if Sys.is_directory path
  then Sys.readdir path
       |> Array.to_list
       |> List.map (fun file ->
              [path; file]
              |> String.concat "/"
              |> files_of_repo)
       |> List.flatten
  else [ path ]

let line_stream_of_file file_path =
  let channel = open_in file_path in
  Stream.from
    (fun _ ->
      try Some (input_line channel)
      with End_of_file -> None)

let stream_filter p stream =
  let rec next i =
    try
      let value = Stream.next stream in
      if p value then Some value else next i
    with Stream.Failure -> None
  in
  Stream.from next

let stream_find p stream =
  try
    let element = stream_filter p stream |> Stream.next in
    Some element
  with Stream.Failure -> None

let stream_map f stream =
  let rec next i =
    try Some (f (Stream.next stream))
    with Stream.Failure -> None in
  Stream.from next

let stream_collect f stream =
  let rec next i =
    try
      let value = stream |> Stream.next |> f in
      match value with
      | Some _ -> value
      | None -> next i
    with Stream.Failure -> None
  in
  Stream.from next

let indexed_stream stream =
  let rec next count =
    try
      Some (count, Stream.next stream)
    with Stream.Failure -> None
  in
  Stream.from next

let empty_todo =
  {
    id = None;
    title = "";
    location = None
  }

let option_iter f o =
  match o with
  | Some x -> f x
  | None -> ()

let option_default d o =
  match o with
  | Some x -> x
  | None -> d

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

let todos_of_file file_path =
  file_path
  |> line_stream_of_file
  |> indexed_stream
  |> stream_collect (fun (index, line) ->
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
                  |> option_default "<none>")
                 todo.title

let find_todo_by_id todos search_id =
  todos
  |> stream_find (fun todo ->
       todo.id
       |> TodoOption.flat_map (fun id ->
              if search_id == id
              then Some id
              else None)
       |> TodoOption.is_some)

let _ =
  match Sys.argv |> Array.to_list with
  | [] -> usage ()
  | [_] -> usage ()
  | _ :: files -> files
                  |> List.map (fun file ->
                         file
                         |> todos_of_file
                         |> stream_as_list)
                  |> List.flatten
                  |> List.iter (fun todo ->
                         todo
                         |> todo_as_string
                         |> print_endline)

type location_t =
  {
    file_path : string;
    line_number : int;
  }

let location file_path line_number =
  {
    file_path = file_path;
    line_number = line_number
  }

let location_as_string file_location =
  Printf.sprintf "%s:%d"
                 file_location.file_path
                 file_location.line_number

let stream_of_lines file_path =
  let channel = open_in file_path in
  Stream.from
    (fun _ ->
      try Some (input_line channel)
      with End_of_file -> None)

let rec file_stream_of_dir_tree path : string Stream.t =
  if Sys.is_directory path
  then path
       |> Sys.readdir
       |> Array.to_list
       |> Stream.of_list
       |> TodoStream.map (fun name ->
              name
              |> Filename.concat path
              |> file_stream_of_dir_tree)
       |> TodoStream.flatten
  else Stream.of_list [path]

(* TODO: Implement replace_file_with_stream *)
let replace_file_with_stream file_path stream =
  failwith "TodoFile.replace_file_with_stream unimplemented yet"

(* TODO(#29): Implement replace_line_at_file_location *)
let replace_line_at_location (location: location_t)
                             (new_line: string): unit =
  location.file_path
  |> stream_of_lines
  |> TodoStream.indexed
  |> TodoStream.map (fun (line_number, origin_line) ->
         if line_number == location.line_number
         then new_line
         else origin_line)
  |> replace_file_with_stream location.file_path

open Batteries

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
  Enum.from_while
    (fun _ ->
      try Some (input_line channel)
      with End_of_file ->
        close_in channel;
        None)

let rec file_stream_of_dir_tree path : string Enum.t =
  if Sys.is_directory path
  then path
       |> Sys.readdir
       |> Array.to_list
       |> List.enum
       |> Enum.map (fun name ->
              name
              |> Filename.concat path
              |> file_stream_of_dir_tree)
       |> Enum.flatten
  else List.enum [path]

let replace_file_with_stream (file_path: string) (stream: string Enum.t) =
  let channel = open_out file_path in
  stream |> Enum.iter (fun line -> Printf.fprintf channel "%s\n" line);
  close_out channel

(* TODO(#45): replace_line_at_location remove the entire content of the file *)
let replace_line_at_location (location: location_t)
                             (new_line: string): unit =
  location.file_path
  |> stream_of_lines
  |> Enum.mapi (fun line_number origin_line ->
         if line_number == location.line_number
         then new_line
         else origin_line)
  |> replace_file_with_stream location.file_path

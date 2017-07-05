let stream_of_lines file_path =
  let channel = open_in file_path in
  Stream.from
    (fun _ ->
      try Some (input_line channel)
      with End_of_file -> None)

let rec files_of_dir_tree path =
  if Sys.is_directory path
  then Sys.readdir path
       |> Array.to_list
       |> List.map (fun file ->
              [path; file]
              |> String.concat "/"
              |> files_of_dir_tree)
       |> List.flatten
  else [ path ]

let file_stream_of_dir_tree path : string Stream.t =
  failwith "Not implemented yet"

let root_of_git_repo path: string =
  failwith "Not implemented yet"

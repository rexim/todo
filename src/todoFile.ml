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
              Filename.concat path file
              |> files_of_dir_tree)
       |> List.flatten
  else [ path ]

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

let rec root_of_git_repo path : string option =
  let parent_path = Filename.dirname path
  in if Sys.is_directory path
     then TodoOption.first_some
            (path
             |> Sys.readdir
             |> Array.to_list
             |> List.exists (String.equal ".git")
             |> TodoOption.of_bool path)
            ((not (String.equal parent_path path))
             |> TodoOption.of_bool parent_path
             |> TodoOption.flat_map root_of_git_repo)
     else root_of_git_repo parent_path

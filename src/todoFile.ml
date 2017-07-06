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

(* TODO(#8): traversable layer of abstraction over FS APIs from Sys module
 *
 * Right now, any possible implementations of `file_stream_of_dir_tree` and `root_of_git_repo`
 * will be coupled with FS API from `Sys` module, which makes them really difficult to
 * unit test.
 *
 * We propose to implement a mockable API over `Sys`, which consist of the following
 * core type:
 *
 * ```ocaml
 * type node =
 *   | DirNode of (string * node Stream.t)
 *   | FileNode of string
 * ```
 *
 * Such type is really simple to traverse and mock.
 *
 * Once the API is done, we need to implement `file_stream_of_dir_tree` and
 * `root_of_git_repo` functions using it.
 *)

let file_stream_of_dir_tree path : string Stream.t =
  failwith "Not implemented yet"

let root_of_git_repo path : string =
  failwith "Not implemented yet"

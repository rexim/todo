(* TODO(#37): replace TodoStream with Enum from Batteries *)

let as_list stream =
  let result = ref [] in
  begin
    Stream.iter (fun x -> result := x :: !result) stream;
    List.rev !result
  end

let filter p stream =
  let rec next i =
    try
      let value = Stream.next stream in
      if p value then Some value else next i
    with Stream.Failure -> None
  in
  Stream.from next

let map f stream : 'a Stream.t =
  let rec next _ =
    try
      let value = Stream.next stream in
      Some (f value)
    with Stream.Failure -> None
  in
  Stream.from next

let find p stream =
  try
    let element = filter p stream |> Stream.next in
    Some element
  with Stream.Failure -> None

let collect f stream =
  let rec next i =
    try
      let value = stream |> Stream.next |> f in
      match value with
      | Some _ -> value
      | None -> next i
    with Stream.Failure -> None
  in
  Stream.from next

let indexed stream =
  let rec next count =
    try
      Some (count, Stream.next stream)
    with Stream.Failure -> None
  in
  Stream.from next

let flatten (streams: 'a Stream.t Stream.t) : 'a Stream.t =
  let current_stream = ref None in
  let rec next i =
    try
      let stream =
        match !current_stream with
        | Some stream -> stream
        | None ->
           let stream = Stream.next streams in
           current_stream := Some stream;
           stream in
      try Some (Stream.next stream)
      with Stream.Failure -> (current_stream := None; next i)
    with Stream.Failure -> None in
  Stream.from next

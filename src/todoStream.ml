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

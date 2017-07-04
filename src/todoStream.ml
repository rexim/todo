let as_list stream =
  let result = ref [] in
  begin
    Stream.iter (fun x -> result := x :: !result) stream;
    List.rev !result
  end

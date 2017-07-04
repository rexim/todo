let first_some o1 o2 =
  match o1 with
  | Some a -> Some a
  | None -> o2

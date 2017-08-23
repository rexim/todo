(* TODO(#36): replace TodoOption with BatOption from batteries *)

let first_some o1 o2 =
  match o1 with
  | Some a -> Some a
  | None -> o2

let of_bool v b =
  if b
  then Some v
  else None

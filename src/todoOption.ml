(* TODO(#36): replace TodoOption with BatOption from batteries *)

let of_bool v b =
  if b
  then Some v
  else None

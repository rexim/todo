let first_some o1 o2 =
  match o1 with
  | Some a -> Some a
  | None -> o2

let flat_map f o =
  match o with
  | Some x -> f x
  | None -> None

let map f o =
  match o with
  | Some x -> Some (f x)
  | None -> None

let is_some o =
  match o with
  | Some _ -> true
  | None -> false

let default d o =
  match o with
  | Some x -> x
  | None -> d
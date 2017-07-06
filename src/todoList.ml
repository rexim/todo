let string_of_list string_of_element xs =
  xs
  |> List.map string_of_element
  |> String.concat "; "

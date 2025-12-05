[@@@ocaml.warning "-32"]

type range = { first : int; last : int }

let is_in_range num { first; last } = first <= num && num <= last

let fresh_ingredients ranges ingredients =
  ingredients |> List.filter (fun x -> List.exists (is_in_range x) ranges)

let parse_range range =
  let nums = range |> String.split_on_char '-' in
  let first = List.hd nums in
  let last = List.nth nums 1 in
  { first = int_of_string first; last = int_of_string last }

let parse_ranges ranges =
  ranges |> String.split_on_char '\n' |> List.map parse_range

let parse_ingredients ingredients =
  ingredients |> String.split_on_char '\n' |> List.map int_of_string

let parse_input input =
  let nums = input |> String.trim |> Str.split (Str.regexp "\n\n") in
  let first = List.hd nums in
  let last = List.nth nums 1 in
  (parse_ranges first, parse_ingredients last)

let read_file_to_string (filename : string) : string =
  let ic = open_in filename in
  let s = really_input_string ic (in_channel_length ic) in
  close_in ic;
  s

let () =
  let input = read_file_to_string "inputs/input.txt" in
  let ranges, ingredients = parse_input input in
  let fresh = fresh_ingredients ranges ingredients |> List.length in
  print_int fresh;
  print_newline ()

[@@@ocaml.warning "-32"]
[@@@ocaml.warning "-27"]

type position = Start of int | End of int

(* Start 3 End 5 Start 10 Start 12 End 14 Start 16 End 18 End 20 *)
(* Start 3 End 5 Start 10 End 20 *)
(* [ ] [  [  ]  [  ] ] *)

let join_positions (ps : position list) : position list =
  let rec aux depth acc = function
    | [] -> List.rev acc
    | Start x :: tl ->
        if depth = 0 then aux (depth + 1) (Start x :: acc) tl
        else aux (depth + 1) acc tl
    | End x :: tl ->
        let depth' = depth - 1 in
        if depth' = 0 then aux depth' (End x :: acc) tl else aux depth' acc tl
  in
  aux 0 [] ps

let rec sum_ranges = function
  | Start x :: End y :: tl -> y - x + 1 + sum_ranges tl
  | _ -> 0

type range = { first : int; last : int }

let sum = List.fold_left (fun acc x -> acc + x) 0
let range_to_list { first; last } = [ Start first; End last ]

let compare_position a b =
  match (a, b) with
  | Start x, Start y -> compare x y
  | End x, End y -> compare x y
  | Start x, End y ->
      let c = compare x y in
      if c <> 0 then c else -1
  | End x, Start y ->
      let c = compare x y in
      if c <> 0 then c else 1

let rec fresh_count = function
  | [] -> 0
  | _ :: [] -> 1
  | x :: y :: tl -> y - x + 1 + fresh_count tl

let fresh_ingredients ranges =
  ranges |> List.map range_to_list |> List.flatten |> List.sort compare_position
  |> join_positions |> sum_ranges

let parse_range range =
  let nums = range |> String.split_on_char '-' in
  let first = List.hd nums in
  let last = List.nth nums 1 in
  { first = int_of_string first; last = int_of_string last }

let parse_ranges ranges =
  ranges |> String.split_on_char '\n' |> List.map parse_range

let parse_input input =
  let nums = input |> String.trim |> Str.split (Str.regexp "\n\n") in
  let first = List.hd nums in
  parse_ranges first

let read_file_to_string (filename : string) : string =
  let ic = open_in filename in
  let s = really_input_string ic (in_channel_length ic) in
  close_in ic;
  s

let () =
  let input = read_file_to_string "inputs/input.txt" in
  let ranges = parse_input input in
  let fresh = fresh_ingredients ranges in
  print_int fresh;
  print_newline ()

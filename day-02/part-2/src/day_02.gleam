import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import simplifile

pub type Range {
  Range(start: Int, end: Int)
}

pub type Input =
  List(Range)

pub fn parse_range(str: String) -> Option(Range) {
  string.split_once(str, on: "-")
  |> option.from_result()
  |> option.then(fn(range) {
    let start = range.0 |> to_int
    let end = range.1 |> to_int

    case start, end {
      Some(start), Some(end) -> Some(Range(start, end))
      _, _ -> None
    }
  })
}

pub fn parse_input(str: String) -> List(Range) {
  str
  |> string.trim()
  |> string.split(on: ",")
  |> list.map(parse_range)
  |> option.values
}

fn to_int(s: String) -> Option(Int) {
  int.parse(s)
  |> option.from_result
}

fn is_invalid(id: Int, idx: Int) -> Bool {
  let id_string = id |> int.to_string |> string.to_graphemes
  let id_string_length = list.length(id_string)

  case idx == id_string_length {
    True -> False
    False -> {
      let segments = id_string |> list.sized_chunk(idx)
      let assert Ok(first) = list.first(segments)

      let invalid = list.all(segments, fn(segment) { segment == first })

      case invalid {
        True -> True
        False -> is_invalid(id, idx + 1)
      }
    }
  }
}

fn invalid_ids_inner(range: Range, curr: Int, ids: List(Int)) {
  case curr == range.end + 1 {
    True -> ids
    False -> {
      let new_count = case is_invalid(curr, 1) {
        True -> {
          list.append(ids, [curr])
        }
        False -> ids
      }

      invalid_ids_inner(range, curr + 1, new_count)
    }
  }
}

pub fn invalid_ids(range: Range) -> List(Int) {
  invalid_ids_inner(range, range.start, [])
}

pub fn main() {
  let assert Ok(contents) = simplifile.read(from: "inputs/input.txt")

  let sum = parse_input(contents) |> list.flat_map(invalid_ids) |> int.sum
  echo sum
}

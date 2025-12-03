import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
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

fn is_invalid(id: Int, chunk_size: Int) -> Bool {
  let id_digits = count_digits(id)

  case chunk_size == id_digits {
    True -> False
    False -> {
      let segments = digit_chunks(id, chunk_size)
      let assert Ok(first) = list.first(segments)

      let all_equal = list.all(segments, fn(segment) { segment == first })

      let segment_count = ceiling_div(id_digits, chunk_size)
      let correct_length = list.length(segments) == segment_count

      case all_equal && correct_length {
        True -> True
        False -> is_invalid(id, chunk_size + 1)
      }
    }
  }
}

pub fn digit_chunks(num: Int, size: Int) -> List(Int) {
  digit_chunks_inner(num, size, [])
}

fn digit_chunks_inner(num: Int, size: Int, nums: List(Int)) -> List(Int) {
  let digits = count_digits(num)
  let at = digits - size

  case split_int(num, at) {
    None -> list.reverse(nums)
    Some(#(first, second)) -> digit_chunks_inner(second, size, [first, ..nums])
  }
}

fn split_int(id: Int, at: Int) -> Option(#(Int, Int)) {
  let power = int_power(10, at)

  let first = id / power
  let second = id - { first * power }

  case first == 0 && second == id {
    True -> None
    False -> Some(#(first, second))
  }
}

pub fn count_digits(num: Int) -> Int {
  count_digits_inner(num, 0)
}

fn count_digits_inner(num: Int, count: Int) -> Int {
  case num > 0 {
    True -> count_digits_inner(num / 10, count + 1)
    False -> count
  }
}

fn int_power(base: Int, power: Int) -> Int {
  let power = int.to_float(power)
  let assert Ok(num) = int.power(base, power) |> result.map(float.truncate)
  num
}

fn ceiling_div(num1: Int, num2: Int) -> Int {
  int.to_float(num1) /. int.to_float(num2)
  |> float.ceiling
  |> float.truncate
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
  let assert Ok(contents) = simplifile.read(from: "inputs/example.txt")

  let sum = parse_input(contents) |> list.flat_map(invalid_ids) |> int.sum
  echo sum
}

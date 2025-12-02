import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn parse_input(input: String) -> List(#(Int, Int)) {
  input
  |> string.split(",")
  |> list.filter_map(fn(x) {
    case string.split(x, "-") {
      [from, to] -> {
        use start <- result.try(int.parse(from))
        use end <- result.try(int.parse(to))
        Ok(#(start, end))
      }
      _ -> Error(Nil)
    }
  })
}

fn is_divisor(x: Int, n: Int, next: fn() -> Bool) -> Bool {
  case x % n {
    0 -> next()
    _ -> False
  }
}

fn is_number_repeated_twice(n: Int) -> Bool {
  let n_str = int.to_string(n)
  let len = string.length(n_str)

  use <- is_divisor(len, 2)
  let mid = len / 2
  let first_half = string.slice(n_str, 0, mid)
  let second_half = string.slice(n_str, mid, mid)

  first_half == second_half
}

pub fn part1(input: String) -> Int {
  parse_input(input)
  |> list.map(fn(range) {
    let #(from, to) = range
    list.range(from, to)
    |> list.fold(0, fn(acc, x) {
      case is_number_repeated_twice(x) {
        True -> acc + x
        False -> acc
      }
    })
  })
  |> list.fold(0, int.add)
}

fn is_number_repeated_generic(n: Int) -> Bool {
  let n_str = int.to_string(n)
  let len = string.length(n_str)

  // If len = 1 then max_k = 0, but list.range(1, max_k) then produces [1, 0]
  let max_k = len / 2
  case len >= 2 {
    True -> list.range(1, max_k)
    False -> []
  }
  |> list.any(fn(k) {
    use <- is_divisor(len, k)
    let pattern = string.slice(n_str, 0, k)
    let repeat = len / k

    string.repeat(pattern, repeat) == n_str
  })
}

pub fn part2(input: String) -> Int {
  parse_input(input)
  |> list.flat_map(fn(range) { list.range(range.0, range.1) })
  |> list.filter(is_number_repeated_generic)
  |> list.fold(0, int.add)
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day02.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))

  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}

import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import simplifile

type Vec2 {
  Vec2(x: Int, y: Int)
}

fn str_to_int(in: String) -> Int {
  int.parse(in)
  |> result.unwrap(0)
}

fn list_to_vec2(in: List(String)) -> Vec2 {
  case in {
    [x, y] -> Vec2(str_to_int(x), str_to_int(y))
    _ -> Vec2(0, 0)
  }
}

fn parse_input(input: String) -> List(Vec2) {
  input
  |> string.split("\n")
  |> list.map(fn(row) {
    row
    |> string.split(",")
    |> list_to_vec2
  })
}

pub fn part1(input: String) -> Int {
  input
  |> parse_input
  |> list.combination_pairs
  |> list.fold(0, fn(acc, pair) {
    let #(v1, v2) = pair

    let diff_x = int.absolute_value(v1.x - v2.x) + 1
    let diff_y = int.absolute_value(v1.y - v2.y) + 1
    let area = diff_x * diff_y

    case acc < area {
      True -> area
      False -> acc
    }
  })
}

pub fn part2(input: String) -> Int {
  0
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day09.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))
  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}

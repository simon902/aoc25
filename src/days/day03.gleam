import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn parse_input(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(x) {
    x
    |> string.to_graphemes
    |> list.filter_map(int.parse)
  })
}

fn pow(base: Int, exp: Int) -> Int {
  int.power(base, exp |> int.to_float)
  |> result.unwrap(0.0)
  |> float.truncate
}

pub fn maximize_joltage(curr_max: Int, x: Int, width: Int) {
  list.range(1, width)
  |> list.fold(curr_max, fn(acc, i) {
    let top_scale = pow(10, width + 1 - i)
    let top_half = curr_max / top_scale
    let bottom_half = curr_max % pow(10, width - i)
    let v = { top_half * top_scale } + { bottom_half * 10 } + x

    int.max(acc, v)
  })
}

fn get_maximum_joltage(bank: List(Int), width: Int) -> Int {
  list.fold(bank, 0, fn(acc, x) { maximize_joltage(acc, x, width) })
}

fn solve(input: String, width: Int) -> Int {
  parse_input(input)
  |> list.map(fn(x) { get_maximum_joltage(x, width) })
  |> list.fold(0, int.add)
}

pub fn part1(input: String) -> Int {
  solve(input, 2)
}

pub fn part2(input: String) -> Int {
  solve(input, 12)
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day03.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))
  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}

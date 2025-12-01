import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import simplifile

type Rotation {
  Left(Int)
  Right(Int)
}

fn parse_rotation(line: String) -> Result(Rotation, String) {
  let assert Ok(dir) = string.first(line)
  let line_tail = string.drop_start(line, 1)
  let assert Ok(len) = int.parse(line_tail)

  case dir {
    "L" -> Ok(Left(len))
    "R" -> Ok(Right(len))
    _ -> Error("Invalid Direction")
  }
}

fn parse_input(input: String) -> Result(List(Rotation), String) {
  input
  |> string.split("\n")
  |> list.map(parse_rotation)
  |> result.all
}

fn extract_rotation(rot: Rotation) -> Int {
  case rot {
    Left(n) | Right(n) -> n
  }
}

fn get_new_pos(rot: Rotation, pos: Int) -> Int {
  let n = case rot {
    Left(n) -> -n
    Right(n) -> n
  }
  { { { pos + n } % 100 } + 100 } % 100
}

pub fn part1(input: String) -> Int {
  let assert Ok(input_parsed) = parse_input(input)

  list.fold(input_parsed, #(50, 0), fn(acc, operation) {
    let #(pos, counter) = acc
    let new_pos = get_new_pos(operation, pos)

    let new_count =
      counter
      + case new_pos == 0 {
        True -> 1
        False -> 0
      }
    #(new_pos, new_count)
  })
  |> pair.second
}

pub fn part2(input: String) -> Int {
  let assert Ok(input_parsed) = parse_input(input)

  list.fold(input_parsed, #(50, 0), fn(acc, operation) {
    let #(pos, counter) = acc
    let new_pos = get_new_pos(operation, pos)

    let new_count =
      counter
      + result.unwrap(int.divide(extract_rotation(operation), 100), 0)
      + case operation {
        Left(_) if new_pos > pos -> 1
        Right(_) if new_pos < pos -> 1
        _ -> 0
      }
    #(new_pos, new_count)
  })
  |> pair.second
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day01.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))

  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}

import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile

type Machine {
  Machine(target: Int, buttons: List(Int))
}

fn parse_input(input: String) -> Result(List(Machine), Nil) {
  input
  |> string.split("\n")
  |> list.map(parse_machine)
  |> result.all
}

fn parse_machine(input: String) -> Result(Machine, Nil) {
  let parts = string.split(input, " ")

  use diagram_str <- result.try(list.first(parts))

  let target =
    diagram_str
    |> string.replace("[", "")
    |> string.replace("]", "")
    |> string.to_graphemes
    |> list.map(fn(char) { char == "#" })
    |> bools_to_mask

  let buttons =
    parts
    |> list.filter(string.starts_with(_, "("))
    |> list.map(parse_button)

  Ok(Machine(target, buttons))
}

fn bools_to_mask(bools: List(Bool)) -> Int {
  list.index_fold(bools, 0, fn(acc, index_on, index) {
    case index_on {
      True -> int.bitwise_or(acc, int.bitwise_shift_left(1, index))
      False -> acc
    }
  })
}

fn ints_to_mask(ints: List(Int)) -> Int {
  list.fold(ints, 0, fn(acc, index) {
    let bit = int.bitwise_shift_left(1, index)
    int.bitwise_or(acc, bit)
  })
}

fn parse_button(button_str: String) -> Int {
  button_str
  |> string.replace("(", "")
  |> string.replace(")", "")
  |> string.split(",")
  |> list.filter_map(int.parse)
  |> ints_to_mask
}

fn find_min_presses(machine: Machine, current_state: Int) -> Option(Int) {
  case machine.buttons {
    [] -> {
      case machine.target == current_state {
        True -> Some(0)
        False -> None
      }
    }
    [button, ..buttons_rest] -> {
      let new_machine = Machine(machine.target, buttons_rest)
      let res_skip = find_min_presses(new_machine, current_state)

      let res_press = case
        find_min_presses(
          new_machine,
          int.bitwise_exclusive_or(current_state, button),
        )
      {
        Some(count) -> Some(count + 1)
        None -> None
      }

      case res_skip, res_press {
        Some(x), Some(y) -> Some(int.min(x, y))
        Some(x), None -> Some(x)
        None, Some(y) -> Some(y)
        None, None -> None
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  let assert Ok(machines) = parse_input(input)

  list.map(machines, find_min_presses(_, 0))
  |> list.filter_map(fn(x) { option.to_result(x, Nil) })
  |> list.fold(0, int.add)
}

pub fn part2(input: String) -> Int {
  0
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day10.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))
  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}

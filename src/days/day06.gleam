import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Operation {
  Add
  Multiply
}

type Problem {
  Problem(op: Operation, nums: List(Int))
}

fn str_to_op(in: String) -> Result(Operation, Nil) {
  case in {
    "+" -> Ok(Add)
    "*" -> Ok(Multiply)
    _ -> Error(Nil)
  }
}

fn list_str_to_int(in: List(String)) -> List(Int) {
  in
  |> list.map(fn(x) {
    int.parse(x)
    |> result.unwrap(0)
  })
}

fn combine_ops_and_numbers(
  ops: List(String),
  numbers: List(List(Int)),
) -> List(Problem) {
  list.zip(ops, numbers)
  |> list.map(fn(x) {
    let #(op_str, numbers) = x
    let assert Ok(op) = str_to_op(op_str)

    Problem(op, numbers)
  })
}

fn parse_input_part1(input: String) -> List(Problem) {
  let assert [ops, ..all_numbers_str] =
    input
    |> string.split("\n")
    |> list.map(fn(row) {
      row
      |> string.split(" ")
      |> list.filter(fn(x) { x != "" })
    })
    |> list.reverse

  // Construct a List(List(Int)) from the columns of the input
  let all_numbers =
    all_numbers_str
    |> list.fold([], fn(acc, row) {
      let row_int = list_str_to_int(row)

      case acc {
        [] -> list.sized_chunk(row_int, 1)
        _ -> {
          row_int
          |> list.zip(acc)
          |> list.map(fn(x) {
            let #(elem_new, acc_column) = x
            [elem_new, ..acc_column]
          })
        }
      }
    })

  combine_ops_and_numbers(ops, all_numbers)
}

fn solve_problems(problems: List(Problem)) -> Int {
  problems
  |> list.map(fn(problem) {
    let #(op, init) = case problem.op {
      Add -> #(int.add, 0)
      Multiply -> #(int.multiply, 1)
    }

    problem.nums
    |> list.fold(init, op)
  })
  |> list.fold(0, int.add)
}

pub fn part1(input: String) -> Int {
  parse_input_part1(input)
  |> solve_problems
}

fn parse_input_part2(input: String) {
  let assert [ops_line, ..numbers_lines] =
    input
    |> string.split("\n")
    |> list.reverse

  let numbers_colwise =
    numbers_lines
    |> list.fold([], fn(acc, new_line) {
      case acc {
        [] ->
          string.to_graphemes(new_line)
          |> list.map(fn(x) {
            case x {
              " " -> ""
              _ -> x
            }
          })
        _ -> {
          string.to_graphemes(new_line)
          |> list.zip(acc)
          |> list.map(fn(x) {
            let #(new_char, curr_column) = x
            let new_num = case new_char {
              " " -> ""
              _ -> new_char
            }
            // Here we need to reverse the way we construct the column string, since above we used list.reverse
            string.append(new_num, curr_column)
          })
        }
      }
    })

  let all_numbers =
    numbers_colwise
    |> list.fold([], fn(acc, new_num) {
      case acc {
        [] -> {
          [[new_num]]
        }
        [x, ..xs] -> {
          case new_num {
            "" -> [[], x, ..xs]
            _ -> [[new_num, ..x], ..xs]
          }
        }
      }
    })
    |> list.map(list_str_to_int)
    |> list.reverse

  ops_line
  |> string.split(" ")
  |> list.filter(fn(x) { x != "" })
  |> combine_ops_and_numbers(all_numbers)
}

pub fn part2(input: String) -> Int {
  parse_input_part2(input)
  |> solve_problems
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day06.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))
  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}

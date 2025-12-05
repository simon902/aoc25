import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type IDRanges =
  List(#(Int, Int))

type Database {
  Database(ranges: IDRanges, ids: List(Int))
}

fn parse_id_ranges(input: String) -> IDRanges {
  input
  |> string.split("\n")
  |> list.filter_map(fn(x) {
    case string.split(x, "-") {
      [from_str, to_str] -> {
        let assert Ok(from) = int.parse(from_str)
        let assert Ok(to) = int.parse(to_str)
        Ok(#(from, to))
      }
      _ -> Error(Nil)
    }
  })
}

fn parse_ids(input: String) -> List(Int) {
  input
  |> string.split("\n")
  |> list.filter_map(int.parse)
}

fn parse_input(input: String) -> Result(Database, Nil) {
  let input_split =
    input
    |> string.split("\n\n")

  case input_split {
    [ranges_str, ids_str] ->
      Ok(Database(parse_id_ranges(ranges_str), parse_ids(ids_str)))
    _ -> Error(Nil)
  }
}

fn is_id_in_db(db: Database, id: Int) -> Bool {
  db.ranges
  |> list.any(fn(range) {
    let #(from, to) = range
    from <= id && id <= to
  })
}

fn combine_and_minimize_id_ranges(db: Database) {
  let new_ranges =
    db.ranges
    |> list.sort(fn(a, b) {
      let #(a_from, _) = a
      let #(b_from, _) = b

      int.compare(a_from, b_from)
    })
    |> list.fold([], fn(acc, elem) {
      case acc {
        [] -> [elem]
        [#(last_from, last_to), ..acc_rest] -> {
          let #(elem_from, elem_to) = elem
          case last_from <= elem_from && elem_from <= last_to {
            True -> {
              case elem_to <= last_to {
                True -> [#(last_from, last_to), ..acc_rest]
                False -> [#(last_from, elem_to), ..acc_rest]
              }
            }
            False -> [elem, ..acc]
          }
        }
      }
    })

  Database(new_ranges, db.ids)
}

pub fn part1(input: String) -> Int {
  let assert Ok(db_unprocessed) = parse_input(input)
  let db = combine_and_minimize_id_ranges(db_unprocessed)

  db.ids
  |> list.count(fn(x) { is_id_in_db(db, x) })
}

pub fn part2(input: String) -> Int {
  let assert Ok(db_unprocessed) = parse_input(input)
  let db = combine_and_minimize_id_ranges(db_unprocessed)

  db.ranges
  |> list.fold(0, fn(acc, range) {
    let #(from, to) = range
    acc + { 1 + to - from }
  })
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day05.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))
  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}

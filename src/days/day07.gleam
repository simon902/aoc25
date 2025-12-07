//// This

import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Tile {
  Beam
  Splitter
  Empty
}

type Grid =
  dict.Dict(Coord, Tile)

type State {
  State(grid: Grid, splitters_hit: Int)
}

fn parse_input(input: String) -> #(Grid, Int, Int) {
  let input_rows =
    input
    |> string.split("\n")

  let width =
    input_rows
    |> list.first
    |> result.unwrap("")
    |> string.length
  let height = list.length(input_rows)

  let grid =
    input_rows
    |> list.index_map(fn(row, y_coord) {
      row
      |> string.to_graphemes
      |> list.index_map(fn(cell, x_coord) {
        case cell {
          "S" -> Ok(#(#(x_coord, y_coord), Beam))
          "^" -> Ok(#(#(x_coord, y_coord), Splitter))
          "." -> Ok(#(#(x_coord, y_coord), Empty))
          _ -> Error(Nil)
        }
      })
    })
    |> list.flatten
    |> list.filter_map(fn(x) { x })
    |> dict.from_list

  #(grid, width, height)
}

fn move_beam(state: State, pos: Coord) -> State {
  let assert Ok(cell_below) = dict.get(state.grid, #(pos.0, pos.1 + 1))

  case cell_below {
    Splitter -> {
      let new_grid =
        state.grid
        |> dict.insert(#(pos.0 - 1, pos.1 + 1), Beam)
        |> dict.insert(#(pos.0 + 1, pos.1 + 1), Beam)

      State(new_grid, state.splitters_hit + 1)
    }
    _ -> {
      let new_grid =
        state.grid
        |> dict.insert(#(pos.0, pos.1 + 1), Beam)

      State(new_grid, state.splitters_hit)
    }
  }
}

pub fn part1(input: String) -> Int {
  let #(grid, width, height) = parse_input(input)

  list.range(0, height - 2)
  |> list.fold(State(grid, 0), fn(state, row) {
    list.range(0, width - 1)
    |> list.fold(state, fn(state, col) {
      let assert Ok(cell) = dict.get(state.grid, #(col, row))

      case cell {
        Beam -> move_beam(state, #(col, row))
        _ -> state
      }
    })
  })
  |> fn(state) { state.splitters_hit }
}

fn count_timelines(
  grid: Grid,
  pos: Coord,
  memo: dict.Dict(Coord, Int),
) -> #(Int, dict.Dict(Coord, Int)) {
  let #(x, y) = pos

  case dict.get(memo, pos) {
    Ok(num_timelines) -> #(num_timelines, memo)
    Error(_) -> {
      let assert Ok(cell_below) = dict.get(grid, #(x, y + 1))

      // Info: This memoization check only slightly reduces the number of recurisve calls
      // while making it harder to read.

      // case dict.get(memo, #(x, y + 1)) {
      // Ok(num_timelines) -> #(num_timelines, memo)
      // _ -> {
      let #(timelines_from_below, updated_memo) = case cell_below {
        Splitter -> {
          let #(left_count, left_memo) =
            count_timelines(grid, #(x - 1, y + 1), memo)
          let #(right_count, right_memo) =
            count_timelines(grid, #(x + 1, y + 1), left_memo)

          #(left_count + right_count, right_memo)
        }
        _ -> count_timelines(grid, #(x, y + 1), memo)
      }
      #(
        timelines_from_below,
        dict.insert(updated_memo, pos, timelines_from_below),
      )
    }
    //   }
    // }
  }
}

pub fn part2(input: String) -> Int {
  let #(grid, width, height) = parse_input(input)

  let assert option.Some(init_pos) =
    grid
    |> dict.fold(option.None, fn(beam_pos, curr_pos, cell) {
      case beam_pos {
        option.None -> {
          case cell {
            Beam -> option.Some(curr_pos)
            _ -> beam_pos
          }
        }
        _ -> beam_pos
      }
    })

  // Generate the memoization map for the last row, i.e., for when the beam finished
  let num_timelines_map =
    list.range(0, width - 1)
    |> list.map(fn(x) {
      let coord = #(x, height - 1)
      #(coord, 1)
    })
    |> dict.from_list

  count_timelines(grid, init_pos, num_timelines_map)
  |> pair.first
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day07.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))
  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}

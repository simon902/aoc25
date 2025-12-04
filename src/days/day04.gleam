import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Coord =
  #(Int, Int)

type Tile {
  Paper
  Nothing
}

type Grid =
  dict.Dict(Coord, Tile)

fn parse_input(input: String) -> Grid {
  input
  |> string.split("\n")
  |> list.index_map(fn(row, y_coord) {
    row
    |> string.to_graphemes
    |> list.index_map(fn(elem, x_coord) {
      case elem {
        "@" -> Ok(#(#(x_coord, y_coord), Paper))
        "." -> Ok(#(#(x_coord, y_coord), Nothing))
        _ -> Error(Nil)
      }
    })
  })
  |> list.flatten
  |> list.filter_map(fn(x) { x })
  |> dict.from_list
}

fn count_neighbors(grid: Grid, coord: Coord) -> Int {
  let offsets = [
    #(-1, -1),
    #(0, -1),
    #(1, -1),
    #(-1, 0),
    #(1, 0),
    #(-1, 1),
    #(0, 1),
    #(1, 1),
  ]

  list.count(offsets, fn(offset) {
    let #(dx, dy) = offset
    case dict.get(grid, #(coord.0 + dx, coord.1 + dy)) {
      Ok(Paper) -> True
      _ -> False
    }
  })
}

pub fn part1(input: String) -> Int {
  let grid = parse_input(input)
  grid
  |> dict.fold(0, fn(acc, coord, elem) {
    case elem {
      Paper -> {
        let num_neighbors = count_neighbors(grid, coord)
        case num_neighbors < 4 {
          True -> acc + 1
          False -> acc
        }
      }
      _ -> acc
    }
  })
}

fn part2_inner(grid: Grid, num_removed: Int) -> Int {
  let initial_size = dict.size(grid)

  let new_grid =
    dict.filter(grid, fn(coord, elem) {
      case elem {
        Paper -> count_neighbors(grid, coord) >= 4
        _ -> True
      }
    })

  let new_size = dict.size(new_grid)
  let diff = initial_size - new_size

  case diff {
    0 -> num_removed
    _ -> part2_inner(new_grid, num_removed + diff)
  }
}

pub fn part2(input: String) -> Int {
  parse_input(input)
  |> part2_inner(0)
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day04.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))
  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}

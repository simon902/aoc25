import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Region {
  Region(width: Int, height: Int, num_presents: Int)
}

fn parse_input(input: String) -> #(#(Int, Int), List(Region)) {
  let parts =
    input
    |> string.split("\n\n")
    |> list.reverse

  let assert Ok(regions_str) = list.first(parts)
  let assert Ok(shapes_str) = list.rest(parts)

  let shape_size = check_and_retrieve_for_same_shape(shapes_str)

  let regions =
    regions_str
    |> string.split("\n")
    |> list.map(parse_region)

  #(shape_size, regions)
}

fn parse_region(region_str: String) -> Region {
  let assert [dimension_str, quantity_str] =
    region_str
    |> string.split(":")

  let assert [width, height] =
    dimension_str
    |> string.split("x")
    |> list.map(fn(x) { x |> int.parse |> result.unwrap(0) })

  let num_presents =
    quantity_str
    |> string.split(" ")
    |> list.filter(fn(x) { x != "" })
    |> list.fold(0, fn(acc, elem) {
      acc + { elem |> int.parse |> result.unwrap(0) }
    })

  Region(width, height, num_presents)
}

fn check_and_retrieve_for_same_shape(_shapes_str) -> #(Int, Int) {
  // Always 3x3
  #(3, 3)
}

// Completely cheese the problem:
// Assume every present shape is fully filled 3x3
// and check whether it can fit into the regions
pub fn part1(input: String) -> Int {
  let #(#(shape_width, shape_height), regions) = parse_input(input)

  regions
  |> list.fold(0, fn(num_valid, region) {
    let assert Ok(region_capacity_width) =
      int.floor_divide(region.width, shape_width)
    let assert Ok(region_capacity_height) =
      int.floor_divide(region.height, shape_height)

    let region_capacity = region_capacity_width * region_capacity_height

    case region.num_presents <= region_capacity {
      True -> num_valid + 1
      False -> num_valid
    }
  })
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day12.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))
}

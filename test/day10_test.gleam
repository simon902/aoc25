import days/day10
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"

pub fn part1_test() {
  test_input |> day10.part1 |> should.equal(7)
}

pub fn part1_real_test() {
  // use <- Timeout(10_000.0)
  let assert Ok(input) =
    simplifile.read("inputs/day10.txt")
    |> result.map(string.trim)

  input |> day10.part1 |> should.equal(399)
}

pub fn part2_test() {
  test_input |> day10.part2 |> should.equal(0)
}

pub fn part2_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day10.txt")
    |> result.map(string.trim)

  input |> day10.part2 |> should.equal(0)
}

import days/day04
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
"

pub fn part1_test() {
  test_input |> day04.part1 |> should.equal(13)
}

pub fn part1_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day04.txt")
    |> result.map(string.trim)

  input |> day04.part1 |> should.equal(1527)
}

pub fn part2_test() {
  test_input |> day04.part2 |> should.equal(43)
}

pub fn part2_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day04.txt")
    |> result.map(string.trim)

  input |> day04.part2 |> should.equal(8690)
}

import days/day01
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"

pub fn part1_test() {
  test_input |> day01.part1 |> should.equal(3)
}

pub fn part1_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day01.txt")
    |> result.map(string.trim)

  input |> day01.part1 |> should.equal(999)
}

pub fn part2_test() {
  test_input |> day01.part2 |> should.equal(6)
}

pub fn part2_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day01.txt")
    |> result.map(string.trim)

  input |> day01.part2 |> should.equal(6099)
}

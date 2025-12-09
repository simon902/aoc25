import days/day09
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

pub fn part1_test() {
  test_input |> day09.part1 |> should.equal(50)
}

pub fn part1_real_test() {
  // use <- Timeout(10_000.0)
  let assert Ok(input) =
    simplifile.read("inputs/day09.txt")
    |> result.map(string.trim)

  input |> day09.part1 |> should.equal(4_763_040_296)
}

pub fn part2_test() {
  test_input |> day09.part2 |> should.equal(24)
}

pub fn part2_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day09.txt")
    |> result.map(string.trim)

  input |> day09.part2 |> should.equal(1_396_494_456)
}

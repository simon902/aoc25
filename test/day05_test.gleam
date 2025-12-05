import days/day05
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = "3-5
10-14
16-20
12-18

1
5
8
11
17
32
"

pub fn part1_test() {
  test_input |> day05.part1 |> should.equal(3)
}

pub fn part1_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day05.txt")
    |> result.map(string.trim)

  input |> day05.part1 |> should.equal(505)
}

pub fn part2_test() {
  test_input |> day05.part2 |> should.equal(14)
}

pub fn part2_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day05.txt")
    |> result.map(string.trim)

  input |> day05.part2 |> should.equal(344_423_158_480_189)
}

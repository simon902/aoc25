import days/day03
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = "987654321111111
811111111111119
234234234234278
818181911112111
"

pub fn part1_test() {
  test_input |> day03.part1 |> should.equal(357)
}

pub fn part1_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day03.txt")
    |> result.map(string.trim)

  input |> day03.part1 |> should.equal(17_524)
}

pub fn part2_test() {
  test_input |> day03.part2 |> should.equal(3_121_910_778_619)
}

pub fn part2_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day03.txt")
    |> result.map(string.trim)

  input |> day03.part2 |> should.equal(173_848_577_117_276)
}

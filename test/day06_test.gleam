import days/day06
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  "

pub fn part1_test() {
  test_input |> day06.part1 |> should.equal(4_277_556)
}

pub fn part1_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day06.txt")
    |> result.map(string.trim)

  input |> day06.part1 |> should.equal(4_771_265_398_012)
}

pub fn part2_test() {
  test_input |> day06.part2 |> should.equal(3_263_827)
}

pub fn part2_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day06.txt")
    |> result.map(string.trim)

  input |> day06.part2 |> should.equal(10_695_785_245_101)
}

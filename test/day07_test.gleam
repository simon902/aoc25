import days/day07
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = ".......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
..............."

pub fn part1_test() {
  test_input |> day07.part1 |> should.equal(21)
}

pub fn part1_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day07.txt")
    |> result.map(string.trim)

  input |> day07.part1 |> should.equal(1579)
}

pub fn part2_test() {
  test_input |> day07.part2 |> should.equal(40)
}

pub fn part2_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day07.txt")
    |> result.map(string.trim)

  input |> day07.part2 |> should.equal(13_418_215_871_354)
}

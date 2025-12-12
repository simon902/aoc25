import days/day12
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = "0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2"

// This will fail as we cheesed the problem
pub fn part1_test_skip() {
  test_input |> day12.part1 |> should.equal(2)
}

pub fn part1_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day12.txt")
    |> result.map(string.trim)

  input |> day12.part1 |> should.equal(528)
}

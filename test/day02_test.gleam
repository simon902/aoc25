import days/day02
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"

pub fn part1_test() {
  test_input |> day02.part1 |> should.equal(1_227_775_554)
}

pub fn part1_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day02.txt")
    |> result.map(string.trim)

  input |> day02.part1 |> should.equal(24_043_483_400)
}

pub fn part2_test() {
  test_input |> day02.part2 |> should.equal(4_174_379_265)
}

pub fn part2_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day02.txt")
    |> result.map(string.trim)

  input |> day02.part2 |> should.equal(38_262_920_235)
}

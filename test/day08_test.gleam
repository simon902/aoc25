import days/day08
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input = "162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689"

pub type Timeout {
  Timeout(Float, fn() -> Nil)
}

pub fn part1_test() {
  test_input |> day08.part1(10) |> should.equal(40)
}

pub fn part1_real_test() {
  use <- Timeout(10_000.0)
  let assert Ok(input) =
    simplifile.read("inputs/day08.txt")
    |> result.map(string.trim)

  input |> day08.part1(1000) |> should.equal(75_582)
}

pub fn part2_test() {
  test_input |> day08.part2 |> should.equal(25_272)
}

pub fn part2_real_test() {
  use <- Timeout(10_000.0)
  let assert Ok(input) =
    simplifile.read("inputs/day08.txt")
    |> result.map(string.trim)

  input |> day08.part2 |> should.equal(59_039_696)
}

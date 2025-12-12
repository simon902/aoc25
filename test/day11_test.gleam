import days/day11
import glacier/should
import gleam/result
import gleam/string
import simplifile

const test_input_part1 = "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"

pub fn part1_test() {
  test_input_part1 |> day11.part1 |> should.equal(5)
}

pub fn part1_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day11.txt")
    |> result.map(string.trim)

  input |> day11.part1 |> should.equal(699)
}

const test_input_part2 = "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"

pub fn part2_test() {
  test_input_part2 |> day11.part2 |> should.equal(2)
}

pub fn part2_real_test() {
  let assert Ok(input) =
    simplifile.read("inputs/day11.txt")
    |> result.map(string.trim)

  input |> day11.part2 |> should.equal(388_893_655_378_800)
}

import argv
import days/day01
import days/day02
import days/day03
import days/day04
import days/day05
import days/day06
import days/day07
import days/day08
import days/day09
import days/day10
import days/day11
import gleam/dict
import gleam/int
import gleam/io
import glint

fn run_day(day: Int) {
  let days =
    dict.from_list([
      #(1, day01.run),
      #(2, day02.run),
      #(3, day03.run),
      #(4, day04.run),
      #(5, day05.run),
      #(6, day06.run),
      #(7, day07.run),
      #(8, day08.run),
      #(9, day09.run),
      #(10, day10.run),
      #(11, day11.run),
    ])

  case dict.get(days, day) {
    Ok(run_fn) -> {
      io.println("--- Running Day " <> int.to_string(day) <> " ---")
      run_fn()
    }
    Error(Nil) ->
      io.println("Error: Day " <> int.to_string(day) <> " not implemented.")
  }
}

fn run_command() -> glint.Command(Nil) {
  // set the help text for the aoc25 command
  use <- glint.command_help("Run Aoc25 days.")
  // register named arg: day
  use day <- glint.named_arg("day")
  // use 0 unnamed args 
  use <- glint.unnamed_args(glint.EqArgs(0))
  // start the body of the command
  // this is what will be executed when the command is called
  use named, _, _ <- glint.command()

  // get day flag
  let day_str = day(named)
  case int.parse(day_str) {
    Ok(day_int) -> run_day(day_int)
    Error(Nil) -> {
      io.println_error("Error: The day argument must be an integer.")
    }
  }
}

pub fn main() {
  // create a new glint instance
  glint.new()
  // set program name
  |> glint.with_name("aoc25")
  // with pretty help enabled, using the built-in colours
  |> glint.pretty_help(glint.default_pretty_help())
  // with a root command that executes the `run_command` function
  |> glint.add(at: [], do: run_command())
  // execute given arguments from stdin
  |> glint.run(argv.load().arguments)
}

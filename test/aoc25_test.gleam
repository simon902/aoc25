import days/day03
import gleeunit

// 1. The main function starts the test runner
pub fn main() {
  gleeunit.main()
}

// 2. A test function (must end in _test)
pub fn max_jolt_test() {
  let res = day03.maximize_joltage(1234, 5, 4)

  assert res == 2345
}

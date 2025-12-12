import re
import sys
from z3 import *


def solve_machine(line):
    parts = line.split("{")
    button_part = parts[0]
    target_part = parts[1].strip().replace("}", "")

    targets = [int(x) for x in target_part.split(",")]

    button_matches = re.findall(r"\(([\d,]+)\)", button_part)

    buttons = []
    for match in button_matches:
        buttons.append([int(x) for x in match.split(",")])

    solver = Optimize()
    x_s = [Int(f"x_{i}") for i in range(len(buttons))]

    # Non-negativity
    for x in x_s:
        solver.add(x >= 0)

    # Equations
    for light_i in range(len(targets)):
        constraint_i = Sum([x_s[i] for i in range(len(buttons)) if light_i in buttons[i]])
        solver.add(constraint_i == targets[light_i])

    solver.minimize(Sum(x_s))

    if solver.check() == sat:
        model = solver.model()
        return model.eval(Sum(x_s)).as_long()
    else:
        print("Error: Unsat")
        exit(-1)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        for line in sys.argv[1].split("\n"):
            sol = solve_machine(line)

            print(sol)
    else:
        print("Error: No input")
        exit(-1)

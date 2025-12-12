from z3 import *

INPUT_FILE = "input.txt"

machines = []
with open("../part-2/inputs/input.txt", "r") as f:
    for parts in [line.strip().split() for line in f]:
        solution = [c == "#" for c in parts[0][1:-1]]
        buttons = [[int(b) for b in button[1:-1].split(",")] for button in parts[1:-1]]
        voltages = [int(v) for v in parts[-1][1:-1].split(",")]
        machines.append([solution, buttons, voltages])
        #print(solution, "\n", buttons, "\n", voltages, "\n")

# Part 2
total = 0
for _, buttons, voltages in machines:
    solver = Solver()

    bvars = [Int(f"a{n}") for n in range(len(buttons))]
    for b in bvars:
        solver.add(b >= 0)

    for i,v in enumerate(voltages):
        vvars = [bvars[j] for j,button in enumerate(buttons) if i in button]
        solver.add(Sum(vvars) == v)

    while solver.check() == sat:
        model = solver.model()
        n = sum([model[d].as_long() for d in model])
        solver.add(Sum(bvars) < n)

    total += n
print(total)

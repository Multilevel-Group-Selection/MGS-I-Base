import random
import matplotlib.pyplot as plt

# -----------
# PARAMETERS
# -----------

# Set size of social space.
rows, cols = 21, 21

# Set initial conditions.  <======== The place to enter parameter values.
initial_percent = 30
density = 0.3
pressure = 7
synergy = 8
effort = 1

# Set simulation length.
tick_max = 100
tick = 0

# Population size is calculated from the size of
# the social space and density.
population = int(density * (cols - 1) * (rows - 1))

# Prepare empty lists.
x, y = [], []
field = []

# -------
# METHODS
# -------

# 
def setup():
    for row in range(rows):
        field.append([-1] * cols)
    count = 0
    while count != population:
        px = random.randint(0, cols - 1)
        py = random.randint(0, rows - 1)
        if field[py][px] == -1:
            field[py][px] = 0
            count += 1
    agents = ask_agents()
    contrib_initial = int(initial_percent / 100.0 * population)
    for agent in agents[:contrib_initial]:
        field[agent[1]][agent[0]] = 1

# 
def ask_agents():
    agents = []
    for row in range(rows):
        for col in range(cols):
            if field[row][col] != -1:
                agents.append((col, row))
    random.shuffle(agents)
    return agents

# 
def count_agents(effort):
    count = 0
    for row in range(rows):
        for col in range(cols):
            if effort == field[row][col]:
                count += 1
    return count

# 
def count_agents_in_Moore(px, py, contribution):
    dirs = [(1, 0), (-1, 0), (0, 1), (0, -1),
            (1, 1), (1, -1), (-1, 1), (-1, -1)]

    count = 1 if field[py][px] == contribution else 0
    for d in dirs:
        mx = (px + d[0]) % cols
        my = (py + d[1]) % rows
        if field[my][mx] == contribution: count += 1
    return count

# 
def count_agents_in_Moore_any(px, py):
    dirs = [(1, 0), (-1, 0), (0, 1), (0, -1),
            (1, 1), (1, -1), (-1, 1), (-1, -1)]

    count = 1
    for d in dirs:
        mx = (px + d[0]) % cols
        my = (py + d[1]) % rows
        if field[my][mx] != -1: count += 1
    return count

# 
def move_to(px, py):
    can_move = []
    dirs = [(1, 0), (-1, 0), (0, 1), (0, -1),
            (1, 1), (1, -1), (-1, 1), (-1, -1)]

    for d in dirs:
        mx = (px + d[0]) % cols
        my = (py + d[1]) % rows
        if field[my][mx] == -1: can_move.append((mx, my))

    if len(can_move) > 0:
        move = random.choice(can_move)
        field[move[1]][move[0]] = field[py][px]
        field[py][px] = -1

# 
def potentially_moving():
    for col, row in ask_agents():
        if effort == field[row][col]:
            if synergy * effort * count_agents_in_Moore(col, row, effort) /\
            count_agents_in_Moore_any(col, row) <= pressure:
                move_to(col, row)
        elif 0 == field[row][col]:
            if effort + synergy * effort * count_agents_in_Moore(col, row, effort) /\
            count_agents_in_Moore_any(col, row) <= pressure:
                move_to(col, row)

# 
def potentially_changing_behavior():
    for col, row in ask_agents():
        if field[row][col] != -1:
            if count_agents_in_Moore_any(col, row) == 1:
                if effort <= pressure:
                    if field[row][col] == 1:
                        field[row][col] = 0
                    else:
                        field[row][col] = 1
            else:
                if field[row][col] == effort:
                    if synergy * effort * count_agents_in_Moore(col, row, effort) /\
            count_agents_in_Moore_any(col, row) <= pressure:
                        field[row][col] = 0
                else:
                    if effort + synergy * effort * count_agents_in_Moore(col, row, effort) /\
            count_agents_in_Moore_any(col, row) <= pressure:
                        field[row][col] = 1


# ----------
# SIMULATION
# ----------                        

# 
setup()
x.append(tick)
y.append((count_agents(1) * 1.0 / (count_agents(1) + count_agents(0)) * 100))
#print ("tick: %d  %f%% contrib: %d non-contrib: %d population: %d" %\
#    (tick, (count_agents(1) * 1.0 / (count_agents(1) + count_agents(0)) * 100), count_agents(1), count_agents(0), count_agents(1) + count_agents(0)))
while True:
    tick += 1
    potentially_moving()
    potentially_changing_behavior()
    percent = (count_agents(1) * 1.0 / (count_agents(1) + count_agents(0)) * 100)
#    print ("tick: %d  %f%% contrib: %d non-contrib: %d population: %d" %\
#    (tick, percent, count_agents(1), count_agents(0), count_agents(1) + count_agents(0)))
    x.append(tick)
    y.append(percent)
    if count_agents(1) == population or count_agents(1) == 0 or tick > tick_max:
        break;


# --------
# PLOTTING
# --------

# 
plt.plot(x, y)
plt.ylim(ymin=0)
plt.title('Contributors')
plt.xlabel('ticks')
plt.ylabel('% of population')
plt.show()
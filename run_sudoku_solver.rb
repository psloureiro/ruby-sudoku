require './sudoku.rb'

@DEBUG = true

# ---- Running solver using a variable as input for the initial grids

#  This grid has errors to test initial validation
grid1 = '5..A1...9472.956.39..76.8.586..37152....B49.6.5.6.1784.31246..8.48.59367.9.378.21'

#  These grids are ok
grid2 = '4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......'
grid3 = '..8.6.3.164371892515.....8..26.815.7..54.......9.............1..6......3.3..7.4..'
grid4 = '480016300002008000005900000000500200000407039060000000730000000000700040000020065'
hard1 = '.....6....59.....82....8....45........3........6..3.54...325..6..................'

# solver(grid1)
# solver(grid2)
# solver(grid3)
# solver(grid4)
# solver(hard1)


# ---- Running solver using a file as input for the initial grids

# solver(from_file('easy50.txt'))
# solver(from_file('top95.txt'))
# solver(from_file('hardest.txt'))
# solver(from_file('top50000.txt'))

# solver(random_grid())

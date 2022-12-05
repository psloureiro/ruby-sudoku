## Solve Every Sudoku Puzzle - Translated from Python

## Reference: http://norvig.com/sudoku.html

## Throughout this program we have:
##   r is a row,    e.g. 'A'
##   c is a column, e.g. '3'
##   s is a square, e.g. 'A3'
##   d is a digit,  e.g. '9'
##   u is a unit,   e.g. ['A1','B1','C1','D1','E1','F1','G1','H1','I1']
##   grid is a grid,e.g. 81 non-blank chars, e.g. starting with '.18...7...
##   values is a hash of possible values, e.g. {'A1':'12349', 'A2':'8', ...}

def cross(par1, par2)
  result = []

  par1.each_char do |a|
    par2.each_char do |b|
      result << a + b
    end
  end

  result
end

@DEBUG   = false

@digits  = '123456789'
@rows    = 'ABCDEFGHI'
@cols    = @digits.dup
@squares = cross(@rows, @cols)

unitlist = []
@cols.each_char { |c| unitlist << cross(@rows, c) }
@rows.each_char { |r| unitlist << cross(r, @cols) }

%w[ABC DEF GHI].each do |rs|
  %w[123 456 789].each do |cs|
    unitlist << cross(rs, cs)
  end
end

@units = {}

@squares.each do |s|
  arr_units = []

  unitlist.each do |u|
    arr_units << u if u.include?(s)
  end

  @units[s] = arr_units
end

@peers = {}

@squares.each do |s|
  peers = []

  @units[s].each do |u|
    peers << u - [s]
  end

  @peers[s] = peers.flatten.uniq
end

@grid_original = {}
@attempts = 1

################ Parse a Grid ################

def parse_grid(grid)
  # To start, every square can be any digit; then assign values from the grid.
  values = {}

  @squares.each do |s|
    values[s] = @digits.dup
  end

  grid_values = grid_hash(grid)

  return false unless grid_values

  grid_hash(grid).each do |s, d|
    return false if @digits.include?(d) && !assign(values, s, d)
  end

  puts "DEBUG: parse_grid -> result values = #{values}" if @DEBUG

  values
end

def grid_hash(grid)
  # Convert grid into a hash of (square: char) with '0' or '.' for empties

  chars = ''
  chars_invalid = ''

  grid.each_char do |c|
    if @digits.include?(c) || '0.'.include?(c)
      chars += c.gsub('0', '.')
      chars_invalid += ' '
    else
      chars_invalid += '^'
    end
  end

  # If length of chars is not equal 81, indicates a problem with the parsing process
  if chars.length != 81
    puts "***  Initial grid: #{grid}"
    puts "                   #{chars_invalid}"
    puts "***  Error in grid values. Characters in the grid must be [0..9] and '.'"
    return false
  end

  result = {}

  @squares.each_with_index do |s, idx|
    result[s] = chars[idx]
  end

  @grid_original = result.clone

  result
end

################ Constraint Propagation ################

def assign(values, square, dig)
  # Eliminates all the other values (except d) from values[s] and propagate
  # Return values, except return false if a contradiction is detected

  other_values = values[square].gsub(dig, '')

  other_values.each_char do |dig2|
    return false unless eliminate(values, square, dig2)
  end

  values
end

def eliminate(values, square, dig)
  # Eliminate d from values[s]; propagate when values or places <= 2.
  # Return values, except return False if a contradiction is detected."""

  return values unless values[square].include?(dig)

  values[square] = values[square].gsub(dig, '')

  ## (1) If a square s is reduced to one value d2, then eliminate d2 from the peers.

  return false if values[square].length.zero? ## Contradiction: removed last value

  if values[square].length == 1
    dig2 = values[square]

    @peers[square].each do |peer|
      return false unless eliminate(values, peer, dig2)
    end
  end

  ## (2) If a unit u is reduced to only one place for a value d, then put it there.

  @units[square].each do |unit|
    dplaces = []

    unit.each do |square3|
      dplaces << square3 if values[square3].include?(dig)
    end

    return false if dplaces.empty?
    return false if dplaces.length == 1 && !assign(values, dplaces[0], dig)
  end

  values
end

################ Search algorithm #############

def search(values)
  return false unless values

  is_solved = true

  @squares.each do |s|
    if values[s].length > 1
      is_solved = false
      break
    end
  end

  if is_solved
    puts("DEBUG: Solved - # Attempts = #{@attempts}") if @DEBUG
    return values
  end

  display(values) if (@attempts % 10_000).zero? && @DEBUG

  @attempts += 1

  squares_aux = []

  @squares.each do |s|
    squares_aux << [values[s].length, s] if values[s].length > 1
  end

  _n, s = squares_aux.min

  values[s].each_char do |d|
    result = search(assign(values.clone, s, d))

    return result if result
  end

  false
end

################ Display as 2-D grid ################

def display(values, index = 1, exec_time = 0.0)
  # Display these values as a 2-D grid."

  return false unless values

  exec_time_fmt = format('%.2f', exec_time)

  puts '==================================================='
  puts "Problem #{index} - Attempts to solve = #{@attempts}"
  puts "  Execution time = #{exec_time_fmt} seconds" if exec_time > 0.0
  puts '==================================================='

  @rows.each_char do |r|
    line_original = ''
    line_solution = ''

    @cols.each_char do |c|
      line_original += "#{@grid_original[r + c]} "
      line_solution += "#{values[r + c]} "

      if '36'.include?(c)
        line_original += '| '
        line_solution += '| '
      end
    end

    filler = if r == 'E'
               '  -->   '
             else
               '        '
             end

    puts "#{line_original}#{filler}#{line_solution}"

    puts '------+-------+------         ------+-------+------' if 'CF'.include?(r)
  end

  true
end

################ Generate a random grid ################

def random_grid(n = 17)
  #  Make a random puzzle with N or more assignments. Restart on contradictions.
  #  Note the resulting puzzle is not guaranteed to be solvable, but empirically
  #  about 99.8% of them are solvable. Some have multiple solutions.
  values = {}

  @squares.each do |square|
    values[square] = @digits.dup
  end

  @squares.shuffle.each do |square|
    break unless assign(values, square, values[square].split('').shuffle.sample)

    ds = []

    @squares.each do |square2|
      ds << values[square2] if values[square2].length == 1
    end

    next unless (ds.length >= n) && (ds.uniq.length >= 8)

    result = ''

    @squares.each do |square3|
      result += if values[square3].length == 1
                  values[square3]
                else
                  '.'
                end
    end

    return result
  end

  random_grid(n)
end

################ Read initial grids from a file ################

def from_file(filename, sep = $INPUT_RECORD_SEPARATOR)
  # Parse the contents of a file into a list of strings, separated by sep.
  puts "Reading initial grids from file '#{filename}'"

  result = File.open(filename).read.strip.split(sep)

  puts "#{result.length} initial grids read"
  puts ''

  result
end

################ Solve a sequence of sudokus ################

def solver(grids)
  # If the parameter is a String, convert it to Array to use the main code to solve problem
  grids = Array(grids) if grids.is_a? String

  grids.each_with_index do |grid, index|
    @attempts = 1

    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    result = search(parse_grid(grid))

    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    exec_time = ending - starting

    display(result, index + 1, exec_time)
  end
end

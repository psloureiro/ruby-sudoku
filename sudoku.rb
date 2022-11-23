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

def cross(a, b)
  puts "cross(#{a},#{b})" if @DEBUG
  result = []
  
  a.each_char do |a|
    b.each_char do |b|
      result << a+b
    end
  end

  return result
end

@DEBUG   = false

@digits  = '123456789'
@rows    = 'ABCDEFGHI'
@cols    = @digits.dup
@squares = cross(@rows, @cols)

unitlist = []
@cols.each_char { |c| unitlist << cross(@rows, c) }
@rows.each_char { |r| unitlist << cross(r, @cols) }

['ABC','DEF','GHI'].each do |rs|
  ['123','456','789'].each do |cs|
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

  puts "parse_grid -> values = #{values}" if @DEBUG
  
  grid_values = grid_hash(grid)
  
  return false if !grid_values

  grid_hash(grid).each do |s,d|
    if (@digits.include?(d)) && (! assign(values, s, d))
      return false
    end
  end

  return values
end

def grid_hash(grid)
  # Convert grid into a hash of (square: char) with '0' or '.' for empties

  chars = ""
  chars_invalid = ""

  grid.each_char do |c|
    if @digits.include?(c) || '0.'.include?(c)
      chars += c.gsub('0','.')
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

  return result
end

################ Constraint Propagation ################

def assign(values, s, d)
  # Eliminates all the other values (except d) from values[s] and propagate
  # Return values, except return false if a contradiction is detected

  other_values = values[s].gsub(d, '')

  other_values.each_char do |d2|
    return false if (! eliminate(values, s, d2))
  end

  return values
end  

def eliminate(values, s, d)
  # Eliminate d from values[s]; propagate when values or places <= 2.
  # Return values, except return False if a contradiction is detected."""

  return values if (! values[s].include?(d))

  values[s] = values[s].gsub(d, '')

  ## (1) If a square s is reduced to one value d2, then eliminate d2 from the peers.

  return false if values[s].length == 0   ## Contradiction: removed last value

  if values[s].length == 1
    d2 = values[s]

    @peers[s].each do |s2|
      return false if (! eliminate(values, s2, d2))
    end
  end

  ## (2) If a unit u is reduced to only one place for a value d, then put it there.

  @units[s].each do |u|
    dplaces = []
    
    u.each do |s3|
      dplaces << s3 if values[s3].include?(d)
    end

    return false if dplaces.length == 0
    return false if (dplaces.length == 1) && (! assign(values, dplaces[0], d))
  end

  return values
end

################ Search algorithm #############

def search(values)
  return false if !values

  is_solved = true
  
  @squares.each do |s|
    if values[s].length > 1
      is_solved = false
      break
    end
  end

  if is_solved
    puts("Solved - Attempts = #{@attempts}") if @DEBUG
    return values
  end

  if (@attempts % 10000 == 0)
    display(values) if @DEBUG
  end 

  @attempts += 1

  squares_aux = []

  @squares.each do |s|
    if values[s].length > 1
      squares_aux << [values[s].length, s]
    end
  end

  n, s = squares_aux.min

  values[s].each_char do |d|
    result = search(assign(values.clone, s, d))

    return result if result
  end

  return false
end

################ Display as 2-D grid ################

def display(values, index=1, exec_time=0.0)
  # Display these values as a 2-D grid."

  return false if !values
  
  exec_time_fmt = "%.2f" % exec_time

  puts "==================================================="
  puts "Problem #{index} - Attempts to solve = #{@attempts}"
  puts "  Execution time = #{exec_time_fmt} seconds" if exec_time > 0.0
  puts "==================================================="

  @rows.each_char do |r|
    line_original = ""
    line_solution = ""
    @cols.each_char do |c|
      line_original += @grid_original[r+c] + " "
      line_solution += values[r+c] + " "

      if "36".include?(c)
        line_original += "| "
        line_solution += "| "
      end
    end

    if r == 'E'
      filler = "  -->   "
    else
      filler = "        "
    end

    puts "#{line_original}#{filler}#{line_solution}"

    if "CF".include?(r)
      puts "------+-------+------         ------+-------+------"
    end
  end

  return true
end

################ Generate a random grid ################

def random_grid(n=17)
  #  Make a random puzzle with N or more assignments. Restart on contradictions.
  #  Note the resulting puzzle is not guaranteed to be solvable, but empirically
  #  about 99.8% of them are solvable. Some have multiple solutions.
  values = {}

  @squares.each do |s|
    values[s] = @digits.dup
  end
	
  @squares.shuffle.each do |s|
    if !assign(values, s, (values[s].split("").shuffle.sample))
      break
	  end
    
    ds = []
    
    @squares.each do |s|
      ds << values[s] if values[s].length == 1
    end

    if (ds.length >= n) && (ds.uniq().length >= 8)
      result = ""
      
      @squares.each do |s|
        if values[s].length == 1
          result += values[s]
        else
          result += "."
        end
      end
      
      return result
    end
  end
	
  return random_grid(n)
end

################ Read initial grids from a file ################

def from_file(filename, sep=$/)
  # Parse the contents of a file into a list of strings, separated by sep.
  puts "Reading initial grids from file '#{filename}'"
  
  result = File.open(filename).read.strip.split(separator=sep)
  
  puts "#{result.length} initial grids read"
  puts ""
  
  return result
end

################ Solve a sequence of sudokus ################

def solver(grids)
  # If the parameter is a String, convert it to Array to use the main code to solve problem
  if grids.is_a? String
	  grids = Array(grids)
  end

  grids.each_with_index do |grid, index|
    exec_time = 0.0
	  @attempts = 1

    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    result = search(parse_grid(grid))

    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    exec_time = ending - starting
  
    display(result, index+1, exec_time)
  end
end

################ Tests #############

grid1 = '5..A1...9472.956.39..76.8.586..37152....B49.6.5.6.1784.31246..8.48.59367.9.378.21'
grid2 = '4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......'
grid3 = '..8.6.3.164371892515.....8..26.815.7..54.......9.............1..6......3.3..7.4..'
grid4 = '480016300002008000005900000000500200000407039060000000730000000000700040000020065'
hard1 = '.....6....59.....82....8....45........3........6..3.54...325..6..................'

#solver(grid1)
#solver(grid2)
solver(grid3)
#solver(grid4)
#solver(hard1)

#solver(from_file('easy50.txt'))
#solver(from_file('top95.txt'))
#solver(from_file('hardest.txt'))
#solver(from_file('top50000.txt'))

#solver(random_grid())

class Board
  attr_reader :squares, :side_length, :winning_lines

  def initialize(side_length)
    @squares = {}
    @side_length = side_length
    @winning_lines = calculate_winning_lines
    reset
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def available_moves
    unmarked_keys
  end

  def center_square_key
    @squares.keys[(side_length ** 2) / 2]
  end

  def draw
    row_squares = rows.map { |row| row.map { |num| @squares[num] } }
    last_row = row_squares.pop

    row_squares.each do |row|
      draw_row(row)
      draw_border(side_length)
    end

    draw_row(last_row)
  end

  def empty?
    marked_keys.empty?
  end

  def lines_with_n_identical_markers(n)
    lines = []
    @winning_lines.each do |line|
      line_squares = squares.values_at(*line)
      if n_identical_markers?(line_squares, n)
        lines << line_squares
      end
    end

    lines
  end        

  def find_threatened_square(marker)
    threatened_lines = lines_with_n_identical_markers(2)
    line = threatened_lines.find do |line|
      line.any? { |square| square.marker == marker }
    end
    line&.find(&:unmarked?)&.number
  end

  def full?
    unmarked_keys.empty?
  end

  def reset
    (1..side_length ** 2).each { |key| @squares[key] = Square.new(key) }
  end

  def marked_keys
    @squares.keys.select { |key| @squares[key].marked? }
  end

  def someone_won?
    !!winning_marker
  end

  def unmarked_center_square_key
    center_square_key if @squares[center_square_key].unmarked?
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def winning_combinations
    winning_lines
  end

  def terminal?
    #end of game
  end

  def winning_marker
    @winning_lines.each do |line|
      line_squares = squares.values_at(*line)
      if n_identical_markers?(line_squares, 3)
        return line_squares.first.marker
      end
    end
    nil
  end

  private

  attr_reader :side_length

  def draw_row(row_squares)
    top = ''
    middle = ''
    bottom = ''

    squares = row_squares.map(&:format)
    squares.each do |square|
      top += square[:top]
      middle += square[:middle]
      bottom += square[:bottom]
    end

    puts top.chomp('|')
    puts middle.chomp('|')
    puts bottom.chomp('|')
  end

  def draw_border(size)
    puts '-----+' * (size - 1) + '-----'
  end
  
  def rows
    num_squares = side_length**2

    (1..num_squares).each_slice(side_length).to_a
  end

  def columns(rows)
    rows.map.with_index do |row, outer_index|
      row.map.with_index { |_, inner_index| rows[inner_index][outer_index] }
    end
  end

  def diagonals
    num_squares = side_length**2
    diagonals = []

    diagonals << (1..num_squares).step(@side_length + 1).to_a
    diagonals << (side_length..num_squares - 1).step(side_length - 1).to_a

    diagonals
  end

  def calculate_winning_lines
    rows + columns(rows) + diagonals
  end

  def n_identical_markers?(squares, n)
    markers = squares.select(&:marked?).map(&:marker)
    return false if markers.size != n
    markers.uniq.size == 1
  end
end
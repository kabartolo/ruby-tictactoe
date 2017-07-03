require_relative 'minimax'

class Board
  def initialize(side_length)
    @side_length = side_length
    @squares = {}
    @winning_lines = calculate_winning_lines

    reset!
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def best_move(computer_marker, human_marker)
    find_threatened_square(computer_marker) ||
      find_threatened_square(human_marker) ||
      center_square_key_if_unmarked ||
      random_square
  end

  def best_move_by_minimax(computer_marker, human_marker)
    minimax = Minimax.new(self, computer_marker, human_marker)
    center_square_key_if_board_empty || minimax.best_move
  end

  def draw
    row_squares = rows.map { |row| row.map { |key| @squares[key] } }
    last_row = row_squares.pop

    row_squares.each do |row|
      draw_row(row)
      draw_border(@side_length)
    end

    draw_row(last_row)
  end

  def end_of_game?
    someone_won? || full?
  end

  def random_square
    unmarked_keys.sample
  end

  def reset!
    (1..@side_length**2).each { |key| @squares[key] = Square.new(key) }
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def winning_marker(num_squares_to_win)
    @winning_lines.each do |line|
      line_squares = @squares.values_at(*line)
      if n_identical_markers?(line_squares, num_squares_to_win)
        return line_squares.first.marker
      end
    end
    nil
  end

  #---Public methods used by Minimax class---

  def available_moves
    unmarked_keys
  end

  def terminal?
    end_of_game?
  end

  # Creates a copy of the current board and returns the
  # hypothetical next state without modifying the actual
  # board used in play.
  def hypothetical_next_state(new_key, new_marker)
    new_board = Board.new(@side_length)

    @squares.each do |key, square|
      new_board[key] = square.marker
    end

    new_board[new_key] = new_marker
    new_board
  end

  def winning_player
    winning_marker(@side_length)
  end

  private

  def calculate_winning_lines
    rows + columns(rows) + diagonals
  end

  def center_square_key
    @squares.keys[(@side_length**2) / 2]
  end

  def center_square_key_if_board_empty
    center_square_key if empty?
  end

  def center_square_key_if_unmarked
    center_square_key if @squares[center_square_key].unmarked?
  end

  def columns(rows)
    rows.map.with_index do |row, outer_index|
      row.map.with_index { |_, inner_index| rows[inner_index][outer_index] }
    end
  end

  def diagonals
    num_squares = @side_length**2
    diagonals = []

    diagonals << (1..num_squares).step(@side_length + 1).to_a
    diagonals << (@side_length..num_squares - 1).step(@side_length - 1).to_a

    diagonals
  end

  def draw_border(size)
    puts '-----+' * (size - 1) + '-----'
  end

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

  def empty?
    marked_keys.empty?
  end

  def find_threatened_square(marker)
    threatened_lines = lines_with_n_identical_markers(@side_length - 1)
    line = threatened_lines.find do |current_line|
      current_line.any? { |square| square.marker == marker }
    end

    threatened_square = line&.find(&:unmarked?)
    threatened_square&.key
  end

  def full?
    unmarked_keys.empty?
  end

  def lines_with_n_identical_markers(n)
    lines = []
    @winning_lines.each do |line|
      line_squares = @squares.values_at(*line)
      if n_identical_markers?(line_squares, n)
        lines << line_squares
      end
    end

    lines
  end

  def marked_keys
    @squares.keys.select { |key| @squares[key].marked? }
  end

  def n_identical_markers?(squares, n)
    markers = squares.select(&:marked?).map(&:marker)
    return false if markers.size != n
    markers.uniq.size == 1
  end

  def rows
    num_squares = @side_length**2

    (1..num_squares).each_slice(@side_length).to_a
  end

  def someone_won?
    !!winning_marker(@side_length)
  end
end

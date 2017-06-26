require_relative 'displayable'
require_relative 'minimax'

class Player
  attr_reader :marker

  def initialize(marker)
    @marker = marker
  end
end

class Human < Player
	include Displayable

	def choose_square(empty_squares)
		options = empty_squares.map(&:to_s)
	  input("Choose a square (#{joiner(options)}):", options).to_i
	end
end

class Computer < Player
	include Minimax

	attr_reader :board

	def initialize(marker, board)
		super(marker)
		@board = board
	end

  def choose_square(difficulty, human_marker)
		case difficulty
	  when :impossible
	    puts "Computer is thinking..."

			minimax = Minimax.new(board, marker, human_marker)
	    board.empty? ? board.center_square_key : minimax(board, marker, human_marker)
	  when :hard
	    find_best_move(human_marker)
	  when :easy
	    choose_random_square
    end
	end

	private

	def choose_center_square_if_available
		board.unmarked_center_square_key
	end

	def choose_random_square
	  board.unmarked_keys.sample
	end

	def find_best_move(human_marker)
		winning_lines = board.winning_lines
	  board.find_threatened_square(marker) ||
	    board.find_threatened_square(human_marker) ||
	    choose_center_square_if_available ||
	    choose_random_square
	end

  def try_move(board, square, new_marker)
    new_board = {}

    board.each do |num, current_marker|
      if num == square
        new_board[square] = new_marker
      else
        new_board[num] = current_marker
      end
    end

    new_board
  end
end

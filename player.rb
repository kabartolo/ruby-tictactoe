require_relative 'displayable'
require_relative 'minimax'

class Player
  attr_reader :marker, :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end

  def add_point!
  	@score += 1
  end

  def reset_score
  	@score = 0
  end

  def to_s
  	@name
  end
end

class Human < Player
	include Displayable

	def initialize(marker)
		super
		@name = choose_name
	end

	def choose_name
		loop do
      prompt('What is your name?')
      new_name = gets.chomp
      return new_name if new_name =~ /^\w+/
      prompt('Not a valid name. The first character must not be a space.')
    end
	end

	def choose_square(empty_squares)
		options = empty_squares.map(&:to_s)
	  input("Choose a square (#{joiner(options)}):", options).to_i
	end
end

class Computer < Player
	attr_reader :board

	def initialize(marker, board)
		super(marker)
		@board = board
		@name = 'Computer'
	end

  def choose_square(difficulty, human_marker)
		case difficulty
	  when :impossible
	    puts "Computer is thinking..."

			minimax = Minimax.new(board, marker, human_marker)
	    board.empty? ? board.center_square_key : minimax.optimal_move
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
end

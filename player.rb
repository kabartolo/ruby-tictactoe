require_relative 'displayable'

class Player
  attr_reader :marker, :score

  def initialize(name)
    @name = name
    @marker = nil
    @score = 0
  end

  def add_point!
    @score += 1
  end

  def reset_score!
    @score = 0
  end

  def to_s
    @name
  end
end

class Human < Player
  include Displayable

  def initialize
    super(player_chooses_name)
  end

  def choose_marker(markers)
    answer = input("Do you want to be #{joiner(markers)}?", markers)
    @marker = answer.upcase
  end

  def choose_square(available_squares)
    options = available_squares.map(&:to_s)
    input("Choose a square (#{joiner(options)}):", options).to_i
  end

  private

  def player_chooses_name
    loop do
      prompt('What is your name?')
      new_name = gets.chomp
      return new_name if new_name =~ /^\w+/
      prompt('Not a valid name. The first character must not be a space.')
    end
  end
end

class Computer < Player
  attr_writer :human_marker

  def initialize(board)
    super('Computer')
    @board = board
    @human_marker = nil
  end

  def choose_marker(options)
    @marker = options.reject { |marker| marker == @human_marker }.sample
  end

  def choose_square(difficulty)
    case difficulty
    when :impossible
      puts "Computer is thinking..."
      find_best_move_by_minimax
    when :hard
      find_best_move_normally
    when :easy
      choose_random_square
    end
  end

  private

  def choose_random_square
    @board.random_square
  end

  def find_best_move_normally
    @board.best_move(marker, @human_marker)
  end

  def find_best_move_by_minimax
    @board.best_move_by_minimax(marker, @human_marker)
  end
end

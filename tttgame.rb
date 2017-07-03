require_relative 'board'
require_relative 'square'
require_relative 'player'
require_relative 'displayable'

class TTTGame
  MARKERS = ['X', 'O'].freeze

  FIRST_TO_MOVE = :choose # :choose, :human, or :computer
  DIFFICULTY = :choose # :choose, :easy, :hard, or :impossible

  WINNING_SCORE = 5
  SIDE_LENGTH = 3

  SIDE_LENGTH_MAX_FOR_IMPOSSIBLE = 3

  include Displayable

  attr_reader :board, :human, :computer, :difficulty

  def initialize
    @board = Board.new(SIDE_LENGTH)
    @human = Human.new
    @computer = Computer.new(board)

    decide_markers
    @first_marker = decide_first_player
    @current_marker = nil

    @difficulty = decide_difficulty

    reset!
    display_welcome_message
  end

  def play
    loop do
      display_board
      play_round
      display_result
      update_scores if winner
      display_scores

      break display_game_winner if game_winner?
      break unless play_again?

      reset!
      display_play_again_message
    end

    restart? ? restart! : display_goodbye_message
  end

  private

  def alternate_player
    @current_marker = (human_turn? ? computer.marker : human.marker)
  end

  def clear_screen_and_display_board
    clear_screen
    display_board
  end

  def computer_moves
    square_key = computer.choose_square(difficulty)

    board[square_key] = computer.marker
  end

  def current_player_moves
    human_turn? ? human_moves : computer_moves
    alternate_player
  end

  def decide_difficulty
    difficulty = if DIFFICULTY == :choose
                   user_chooses_difficulty
                 else
                   DIFFICULTY
                 end

    if difficulty == :impossible && disable_hardest_difficulty?
      prompt("'Impossible' difficulty disabled.")
      difficulty = user_chooses_difficulty
    end

    difficulty
  end

  def decide_first_player
    case FIRST_TO_MOVE
    when :human
      human.marker
    when :computer
      computer.marker
    when :choose
      answer = input("Do you want to go first? (y or n)", %w[y yes n no])
      answer.start_with?('y') ? human.marker : computer.marker
    end
  end

  def decide_markers
    human.choose_marker(MARKERS)
    computer.human_marker = human.marker
    computer.choose_marker(MARKERS)
  end

  def disable_hardest_difficulty?
    SIDE_LENGTH > SIDE_LENGTH_MAX_FOR_IMPOSSIBLE
  end

  def display_game_winner
    case WINNING_SCORE
    when human.score
      prompt("#{human} won the game!")
    when computer.score
      prompt("#{computer} won the game!")
    end
  end

  def display_scores
    puts "#{human}: #{human.score}"
    puts "#{computer}: #{computer.score}"
  end

  def display_board
    prompt("You're #{human.marker}. Computer is #{computer.marker}.")
    puts
    board.draw
  end

  def display_goodbye_message
    prompt("Thanks for playing Tic Tac Toe! Goodbye!")
  end

  def display_play_again_message
    prompt("Let's play again!")
    puts
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker(SIDE_LENGTH)
    when human.marker
      prompt("#{human} won!")
    when computer.marker
      prompt("#{computer} won!")
    else
      prompt("The board is full! It's a tie!")
    end
  end

  def display_welcome_message
    prompt("Hi, #{human}! Welcome to Tic Tac Toe!")
    puts
  end

  def game_winner?
    winner&.score == WINNING_SCORE
  end

  def human_moves
    square_key = human.choose_square(board.unmarked_keys)

    board[square_key] = human.marker
  end

  def human_turn?
    @current_marker == human.marker
  end

  def play_again?
    answer = input("Would you like to play again? (y/n)", %w[y n yes no])
    answer.start_with?('y')
  end

  def play_round
    loop do
      current_player_moves
      break if board.end_of_game?
      clear_screen_and_display_board
    end
  end

  def reset!
    board.reset!
    @current_marker = @first_marker
    clear_screen
  end

  def restart?
    answer = input("Do you want to restart? (y/n)", %w[y n yes no])
    answer.start_with?('y')
  end

  def restart!
    human.reset_score!
    computer.reset_score!
    reset!
    play
  end

  def update_scores
    winner.add_point!
  end

  def user_chooses_difficulty
    if disable_hardest_difficulty?
      message = 'easy (e) or hard (h)'
      options = %w[e easy h hard]
    else
      message = 'easy (e), hard (h), or impossible (i)'
      options = %w[e easy h hard i impossible]
    end

    prompt("Choose your difficulty: ")
    answer = input(message, options)

    case answer.chr
    when 'e' then :easy
    when 'h' then :hard
    when 'i' then :impossible
    end
  end

  def winner
    case board.winning_marker(SIDE_LENGTH)
    when human.marker
      human
    when computer.marker
      computer
    end
  end
end

game = TTTGame.new
game.play

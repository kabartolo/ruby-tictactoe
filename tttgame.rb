require_relative 'board'
require_relative 'square'
require_relative 'player'
require_relative 'displayable'
require 'pry'

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'

  FIRST_TO_MOVE = :choose # :choose, HUMAN_MARKER, or COMPUTER_MARKER
  DIFFICULTY = :choose # :choose, :easy, :hard, or :impossible
  
  WINNING_SCORE = 5
  SIDE_LENGTH = 3

  include Displayable

  attr_reader :board, :human, :computer, :difficulty

  def initialize
    @board = Board.new(SIDE_LENGTH)
    @human = Human.new(HUMAN_MARKER)
    @computer = Computer.new(COMPUTER_MARKER, board)

    @first_marker = decide_first_player
    @current_marker = @first_marker
    @difficulty = decide_difficulty

    display_welcome_message
  end

  def play
    clear_screen

    loop do
      display_board

      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board #if human_turn?
      end

      display_result
      update_scores if winner
      display_scores
      break display_game_winner if game_winner?
      break unless play_again?
      reset
      display_play_again_message
    end

    restart? ? restart : display_goodbye_message
  end

  private

  def alternate_player
    if human_turn?
      @current_marker = COMPUTER_MARKER
    else
      @current_marker = HUMAN_MARKER
    end
  end

  def clear_screen_and_display_board
    clear_screen
    display_board
  end

  def computer_moves
    square_key = computer.choose_square(difficulty, human.marker)

    board[square_key] = computer.marker
  end

  def current_player_moves
    human_turn? ? human_moves : computer_moves
    alternate_player
  end

  def decide_first_player
    return FIRST_TO_MOVE unless FIRST_TO_MOVE == :choose

    answer = input("Do you want to go first? (y or n)", %w[y yes n no])
    answer.start_with?('y') ? HUMAN_MARKER : COMPUTER_MARKER
  end

  def decide_difficulty
    difficulty = if DIFFICULTY == :choose
                   user_inputs_difficulty
                 else
                   DIFFICULTY
                 end

    if difficulty == :impossible && disable_hardest_difficulty?
      prompt("'Impossible' difficulty disabled on boards greater than 3x3.")
      difficulty = user_inputs_difficulty
    end

    difficulty
  end

  def disable_hardest_difficulty?
    SIDE_LENGTH > 3
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

  def update_scores
    winner.add_point!
  end

  def user_inputs_difficulty
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

    case board.winning_marker
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
    @current_marker == HUMAN_MARKER
  end

  def play_again?
    answer = input("Would you like to play again? (y/n)", %w[y n yes no])
    answer.start_with?('y')
  end

  def restart?
    answer = input("Do you want to restart? (y/n)", %w[y n yes no])
    answer.start_with?('y')
  end

  def restart
    human.reset_score
    computer.reset_score
    reset
    play
  end

  def reset
    board.reset
    @current_marker = @first_marker
    clear_screen
  end

  def winner
    case board.winning_marker
    when human.marker 
      human
    when computer.marker
      computer
    end
  end
end

game = TTTGame.new
game.play

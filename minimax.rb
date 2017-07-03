class Minimax
  attr_reader :max_player, :min_player

  def initialize(start_state, max_player, min_player)
    @start_state = start_state
    @max_player = max_player
    @min_player = min_player
  end

  def best_move
    first_available_moves = @start_state.available_moves
    minimaxed_scores = {}

    next_possible_states = first_available_moves.map do |move|
      next_state = @start_state.hypothetical_next_state(move, max_player)
      [next_state, move]
    end

    next_possible_states.each do |next_state, move|
      score = minimax_score(next_state, min_player)
      minimaxed_scores[score] = move
    end

    optimal_score = minimaxed_scores.keys.max
    minimaxed_scores[optimal_score]
  end

  private

  def assess(winning_player)
    case winning_player
    when max_player then 1
    when min_player then -1
    else 0
    end
  end

  def maximized_score(next_possible_states)
    score = -2

    next_possible_states.each do |next_state|
      next_score = minimax_score(next_state, min_player)
      score = [score, next_score].max
    end

    score
  end

  def minimized_score(next_possible_states)
    score = 2

    next_possible_states.each do |next_state|
      next_score = minimax_score(next_state, max_player)
      score = [score, next_score].min
    end

    score
  end

  def minimax_score(state, minimax_player)
    if state.terminal?
      return assess(state.winning_player)
    end

    next_possible_states = state.available_moves.map do |move|
      state.hypothetical_next_state(move, minimax_player)
    end

    case minimax_player
    when max_player
      maximized_score(next_possible_states)
    when min_player
      minimized_score(next_possible_states)
    end
  end
end

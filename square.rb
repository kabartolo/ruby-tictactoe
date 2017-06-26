class Square
  INITIAL_MARKER = ' '

  attr_reader :number
  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER, number)
    @marker = marker
    @number = number
  end

  def format
    layers = { }
    layers[:top] = number.to_s + (' ' * (5 - number.to_s.size)) + '|'
    layers[:middle] = "  #{@marker}  |"
    layers[:bottom] = '     |'

    layers
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

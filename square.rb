class Square
  INITIAL_MARKER = ' '

  attr_reader :key
  attr_accessor :marker

  def initialize(key, marker = INITIAL_MARKER)
    @key = key
    @marker = marker
  end

  def format
    layers = {}
    layers[:top] = key.to_s + (' ' * (5 - key.to_s.size)) + '|'
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

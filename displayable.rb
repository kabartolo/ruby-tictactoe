module Displayable
  def prompt(message)
    puts "=> #{message}"
  end

  def clear_screen
    system('cls') || system('clear')
  end

  def input(message, options)
    downcase_options = options.map(&:downcase)

    prompt(message)
    loop do
      answer = gets.chomp.downcase
      return answer if downcase_options.include?(answer)
      prompt("Please enter #{joiner(options)}.")
    end
  end

  def joiner(array, delimiter = ', ', conjunction = 'or')
    case array.size
    when 0 then ''
    when 1 then array.first
    when 2 then array.join(" #{conjunction} ")
    else
      last_item = delimiter + "#{conjunction} #{array.last}"
      array[0..-2].join(delimiter) + last_item
    end
  end
end

# frozen_string_literal: true

require 'yaml'

# the start of the board
class Board
  attr_reader :result, :word
  def initialize
    line = File.read '5desk.txt'
    @word = line.lines.select { |l| (5..6).cover?(l.strip.size) }.sample.strip.upcase
  end
end
# the start of a game
class Game
  attr_reader :board, :guessed, :final, :answer
  def initialize(player1)
    @player1 = player1
    @board = Board.new
    @guessed = ['1']
    @attempts = 1
    @mode = 0
    @answer = answer
    intro_text
  end

  def self.load_game
    save_file = File.open('save_file.yaml')
    @game = YAML::load(save_file)
    puts "\nWelcome back, #{@player1}"
    @game.game_play
  end

  def save_game
    yaml = YAML::dump(self)
    File.open('save_file.yaml', 'w+') { |x| x.write yaml }
    puts "Game saved\nPress ENTER to continue..."
  end

  def intro_text
    puts "\nIf you would like to start a new game, press 1\n\nIf you would like to load an old game, press 2"
    @mode = gets.chomp.to_i until @mode == 1 || @mode == 2
    if @mode == 1
      game_play
    else
      Game.load_game
    end
  end

  def flipped_answer(guessed)
    guessed_to_string = guessed.join
    @answer = board.word
    @final = answer.tr('^' + guessed_to_string, '_').chars.join
  end

  def guesses
    @guesses = @final
    puts "\nThe word is #{@final.length} letters long"
  end

  def game_play
    flipped_answer(@guessed)
    guesses
    player_guess
  end

  def error_check(user_guess)
    return unless user_guess.length > 1

    puts 'Please enter a single character guess'
    @attempts -= 1 unless @attempts < 1
  end

  def letter_length(user_guess)
    user_guess.each do |letter|
      letter.length > 1 || letter.empty? ? @attempts -= 0 : @attempts += 1
      puts(letter.length > 1 || letter.empty? ? "\n#{letter} -> invalid. 1 character guesses please." : '')
    end
  end

  def letters_guessed(user_guess)
    user_guess.each do |letter|
      @guessed << letter unless letter.length > 1 || letter.empty?
    end
    puts 'You have guessed:'
    p @guessed unless @guessed == []
  end

  def win_con(guessed)
    guessed_to_string = guessed.join
    return unless @final.tr('^' + guessed_to_string, '_').chars.join == @answer.chars.join

    puts "Great job! You guessed #{@final} in #{@attempts} attempts"
    exit
  end

  def save_option
    win_con(@guessed)
    puts 'Would you like to save now? Y/N'
    input = gets.chomp.upcase until input == 'Y' || input == 'N'
    puts "\n"
    puts(input == 'Y' ? save_game : 'Make a guess')
  end

  def player_guess
    puts "\nLet's see if we can guess the word, shall we?"
    while @attempts < 12
      p "This is attempt ##{@attempts}"
      puts flipped_answer(@guessed)
      save_option
      @user_guess = gets.chomp.upcase.split
      error_check(@user_guess)
      letter_length(@user_guess)
      letters_guessed(@user_guess)
      win_con(@guessed)
    end
    puts "\nSorry #{@player1}, the answer was #{@answer}."
  end
end

Game.new('Henry')

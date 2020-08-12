# frozen_string_literal: true

require 'yaml'
require 'colorize'

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
  attr_reader :board, :guessed, :final, :answer, :user_guess, :player1, :swapped
  def initialize(player1)
    @player1 = player1
    @board = Board.new
    @guessed = []
    @attempts = 1
    @mode = 0
    @final = board.word
    @display_content = '_' * @final.length
    intro_text
  end

  def self.load_game
    save_file = File.open('save_file.yaml')
    @game = YAML.load(save_file)
    puts "\nWelcome back, #{@player1}".cyan
    @game.game_play
  end

  def save_game
    yaml = YAML.dump(self)
    File.open('save_file.yaml', 'w+') { |x| x.write yaml }
  end

  def intro_text
    puts "\nIf you would like to start a new game, press 1\n\nIf you would like to load an old game, press 2"
    @mode = gets.chomp.to_i until @mode == 1 || @mode == 2
    if @mode == 1
      puts "\nLets see if we can guess the word, shall we?"
      save_text
      game_play
    else
      Game.load_game
    end
  end

  def flipped_answer(user_guess)
    @final = board.word
    @display_content.to_s

    return unless user_guess.length == 1

    @display_content.length.times do |index|
      @display_content[index] = user_guess if @final[index].upcase == user_guess
    end
  end

  def guesses
    @guesses = @final
    puts "\nThe word is #{@final.length} letters long"
  end

  def game_play
    guesses
    player_guess
  end

  def letters_guessed(user_guess)
    swapped = @guessed.size.times.select { |i| @guessed[i] == user_guess } != []
    user_guess = user_guess.split
    user_guess.each do |letter|
      @guessed << letter unless letter.include?('SAVE') || letter.include?('EXIT') || swapped == true
    end
    puts 'You have guessed:'
    p @guessed unless @guessed == []
  end

  def win_con
    return unless @user_guess == @final

    puts "Nice Job! You guessed the word #{@final} in #{@attempts} attempts!".green
    exit
  end

  def save_option(user_guess)
    win_con
    if user_guess == 'EXIT'
      puts 'Goodbye!'.cyan
      exit
    elsif user_guess == 'SAVE'
      save_game
      puts "\nGame saved...\nContinue guessing".cyan
    else
      win_con
    end
  end

  def save_text
    puts "\nAvailable options are: Save, Exit, or continue guessing."
  end

  def error_check(user_guess)
    return unless @guessed.size.times.select { |i| @guessed[i] == user_guess } != []

    puts 'You already guessed that! Guess again.'.red
    @attempts -= 1 unless @attempts < 1
  end

  def player_guess
    while @attempts < 12
      puts "\nThis is attempt ##{@attempts}".yellow
      puts "\n#{@display_content.chars.join(' ')}"
      @user_guess = gets.chomp.upcase
      error_check(@user_guess)
      letters_guessed(@user_guess)
      puts flipped_answer(@user_guess)
      save_option(@user_guess)
      win_con
      @attempts += 1
    end
    puts "\nSorry #{@player1}, the answer was #{@final}.".yellow
  end
end

Game.new('Henry')

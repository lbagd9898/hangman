require 'colorize'
require 'yaml'

DICTIONARY = []


file = File.open('5desk.txt', 'rb').read
file.each_line do |line|
    line = line.chomp
    if line.length >= 5 && line.length <= 12
        DICTIONARY.push(line)
    end 
end

class Game
    attr_accessor :secret_word, :secret_word_array, :guesses, :display, :remaining_word, :incorrect_guesses_remaining

    def initialize 
        @guesses = {}
        @secret_word = DICTIONARY.sample.upcase
        @secret_word_array = @secret_word.split('')
        @display = " _" * @secret_word.length
        @remaining_word = @secret_word
        @incorrect_guesses_remaining = 10
    end

    def start_options
        loop do 
            puts "Press 1 to start a new game, press 2 to load an existing game."
            input = gets.chomp
            if input == "1"
                puts "Initializing new game.".yellow 
                play
                break
            elsif input == "2"
                load_game
                play 
                break
            else
                puts "Invalid option.".red
            end 
        end
    end

    def play 
        display_stats
        loop do 
            game_round
            display_stats
            if check_for_win
                break
            end
        end
    end

    def game_round
        guess = make_guess
        if guess == "save"
            save_game
            return
        end
        if check_guess(guess)
            puts "Good guess!".green
            index = @remaining_word.index(guess)
            p index
            @remaining_word[index] = " "
            @display[index*2+1] = guess
            @guesses[guess] = true 
            p @remaining_word
        else
            puts "Bad guess :(".red
            @guesses[guess] = false
            @incorrect_guesses_remaining -= 1
        end
    end

    def make_guess
        loop do 
            puts "Enter a letter to make a guess, or type save to \"save your game\"."
            input = gets.chomp
            if input == "save"
                return input
            elsif input.length != 1 || !(input.match?(/[[:alpha:]]/)) 
                puts "Invalid input.".red
                next
            elsif @guesses.key?(input.upcase) 
                puts "You already guessed that letter".red
            else 
                return input.upcase
            end
        end
    end

    def display_stats
        puts ''
        puts "Incorrect guesses remaining: #{@incorrect_guesses_remaining}".yellow 
        guess_list = ''
        @guesses.each do |k, v|
            if v == true 
                guess_list += k.green
            else 
                guess_list += k.red
            end
        end
        puts "Letters guessed: " + guess_list
        puts "Word: " + @display 
        puts ''

    end
    
    def check_for_win
        if @incorrect_guesses_remaining == 0
            puts "You Lost".red
            return true
        elsif @remaining_word =~ /\A\s*\Z/
            puts "You won".green
            return true 
        end
    end

    def check_guess(guess)
        if @remaining_word.include? guess
            true 
        else
            false
        end
    end

    def save_game
        puts "What name would you like to save your game under?"
        saved_game = gets.chomp
        Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
        File.open("./saved_games/#{saved_game}.yml", 'w'){ |f| YAML.dump([] << self, f)}
        exit 
    end 


    def load_game
        game = choose_saved_game
        yaml = YAML.load(File.read("./saved_games/#{game}.yml"))
        puts yaml.inspect
        @guesses = yaml[0].guesses
        @secret_word = yaml[0].secret_word
        @secret_word_array = @secret_word.split('')
        @display = yaml[0].display
        @remaining_word = yaml[0].remaining_word
        @incorrect_guesses_remaining = yaml[0].incorrect_guesses_remaining
    end

    def choose_saved_game()
        saved_games = Dir.glob('./saved_games/*').map { |file| file.split('/')[2].split('.')[0] }
        loop do
            puts "Enter the name of one of the following saved games:"
            puts saved_games
            input = gets.chomp
            if saved_games.include? input
                 return input 
            elsif 
                puts "Please enter a valid game name.".red  
            end
        end
    end


end



game = Game.new()
game.start_options



# [:black, :light_black, :red, :light_red, :green, :light_green, :yellow, :light_yellow, :blue, :light_blue, :magenta, :light_magenta, :cyan, :light_cyan, :white, :light_white, :default]




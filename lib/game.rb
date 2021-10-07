require "set"
require_relative "./player.rb"

class Game
   
    attr_reader :current_player, :losses, :fragment, :players, :dictionary, :remaining_players

    def initialize
        @players = self.get_players
        @fragment = ""
        @dictionary = self.get_dictionary
        @losses = Hash.new { |losses, player| losses[player] = 0 }
        @remaining_players = @players.clone
        system("clear")
    end

    def run
        self.play_round until self.game_over?
        p "GAME OVER! #{@remaining_players[0].name} wins the game!" 
    end
    
    # helper methods 

    def get_dictionary
        words = File.readlines("lib/dictionary.txt").map(&:chomp)
        Set.new(words)
    end

    def get_players
        system("clear")
        puts "Welcome to the GHOST game!"
        puts "Enter number of players:"
        num_players = gets.chomp.to_i
        players = [] 
        num_players.times {players << Player.new}
        players
    end

    def current_player
        @current_player = @remaining_players.first
    end

    def next_player!
        @current_player = @remaining_players.rotate!
    end

    # turn and round methods

    def play_round
        puts "---D I N G !   N E W   R O U N D !---"
        @round_over = false
        take_turn(self.current_player) until @round_over
        if @round_over
            @fragment = ""
            self.display_standings
            sleep 5
            system("clear")
        end
    end

    def game_over?
        @remaining_players.length == 1
    end

    def take_turn(player)
        puts "\n>> #{player.name.upcase}'s turn"
        guess = player.guess(@fragment)
        if !valid_play?(guess) 
            puts "invalid guess; try again"
            take_turn(player)
        else
            system("clear")
            @fragment << guess
            if is_word?(@fragment) 
                puts "---------Oh no! Round over!---------"
                earn_letter(player)
                @round_over = true
            else 
                puts "#{player.name.upcase} successfully added `#{guess}.`"
            end
            self.next_player!
        end
    end

    # guess-checking helper methods

    def valid_play?(guess)
        self.is_letter?(guess) && self.word_possible?(guess)
    end
        
    def is_letter?(guess)
        ("a".."z").to_a.include?(guess)
    end

    def word_possible?(guess) 
        # check if any word could be spelled with additional letters after adding guess to prior fragment
        new_frag = @fragment + guess
        test_dict = @dictionary.dup
        test_dict.select! { |ele| ele =~ /#{new_frag}\w*/ }
        return false if test_dict.length < 1
        
        true
    end

    def is_word?(fragment)
        @dictionary.include?(fragment) 
    end
    
    # scorekeeping helper methods

    def earn_letter(player)
        lost = "lost this round."
        if @losses[player.name] <= 4 
            @losses[player.name] += 1   
        else
            @remaining_players.delete(player)
            lost = "lost the game!"
        end
        puts "#{player.name.upcase} #{lost} `#{@fragment}` is in the dictionary."
        puts "\n"
            
    end

    def record(player_name)
        player_loss_count = self.losses[player_name]
        "GHOST"[0,player_loss_count]
    end

    def display_standings
        puts "----------CURRENT STANDINGS----------"
        if @players.length != @remaining_players.length
            losers = @players.select {|player| !@remaining_players.include?(player)}
            losers_names = losers.each {|loser| loser.name.upcase}
            puts "Out of the game: #{losers_names.join(", ")}"
        end
        @remaining_players.each do |player| 
            if record(player.name) ==""
                puts "#{player.name.upcase} has not received any GHOST letters yet"
            else
                puts "#{player.name.upcase} has #{record(player.name)}"
            end
        end
        puts "\n"
    end


end

if $PROGRAM_NAME == __FILE__
    game = Game.new
    game.run
end
class Player
    attr_reader :name

    def initialize
        puts "Enter player's name:"
        @name = gets.chomp
    end

    def prompt(fragment)
        puts "The current fragment is `#{fragment}`. Add a letter: "
    end

    def guess(fragment)
        prompt(fragment)
        gets.chomp.downcase
    end

    def alert_invalid_move
        puts "Invalid guess. Your guess must be one letter of the alphabet."
        puts "The new fragment must form the start of a word in the dictionary."
    end
end
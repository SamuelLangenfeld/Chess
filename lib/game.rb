require_relative 'board.rb'

class Game

	def initialize
		puts "Welcome to Chess!"
		while menu
		end
		

	end

	def menu
		
		puts "Menu options:"
		puts "0: Instructions"
		puts "1: Start a new game"
		puts "2: Play a game against the computer"
		puts "3: Load a saved game"
		puts "4: Exit"
		input=gets.chomp
		until ('0'..'4').include?(input)
			puts "Enter 1 for a new game, 2 for a game against the computer, 3 to load a game, or 4 to exit"
			input=gets.chomp
		end
		case input
		when "0"
			puts "\nTo move a piece to a chosen square on the board, enter both the name of the starting square and the end square"
			puts "For example, to move the white pawn from A2 to A4, enter 'A2 A4'"
			puts "\nCastling and en passant are both allowed in this game. To castle, select your king and the space you would like to castle to."
			puts "For example, to castle the white king to the left enter 'E1 C1' and the castling will take place"
			puts "Castling is only allowed if the spaces between the rook and king are clear, neither the rook nor king have previously moved, \nand none of the squares the king moves through can be under attack"
			puts "\nTo use the en passant rule, select your pawn and move it to the square behind the enemy pawn that just took a double move."
			puts "The enemy pawn will be captured automatically."
			puts "\nIf you play against the computer, it will make a random legal move each round."
			puts "\nIf the current player is not in check but cannot make a legal move, then the game will end in a draw"
			puts "\nYou can enter 'save' at any point to save your game\n\n"

		when "1"
			new_board=Board.new
			new_board.game_start
		when "2"
			new_board=Board.new(false)
			new_board.game_start
		when "3"
			load_game
		when "4"
			return false
		end
		return true


	end

	def load_game
		puts "Enter the name of your file"
		filename=gets.chomp
		filename="saved_games/"+filename
		until File.exists?(filename)
			puts "The named file doesn't exist. Try another name, or enter 'menu' to go back to the main menu"
			filename=gets.chomp
			if filename.upcase=="MENU"
				return true
			end
			filename="saved_games/"+filename
		end
		new_board=YAML::load(File.open(filename, "r"))
		new_board.game_start

	end



end


new_game=Game.new



require_relative 'pieces.rb'
require_relative 'player.rb'
require 'yaml'

class Board

	attr_accessor :current_player

	#it has pieces, should have 64 right? 8x8

	attr_accessor :squares
	attr_accessor :players

	def initialize(human=true)

		@player1=Player.new("White", :w, true)
		if human
			@player2=Player.new("Black", :b, true)
		else
			@player2=Player.new("Black", :b, false)
		end
		@players=[@player1, @player2]
		@current_player=@player1
	

		@squares = {}

		for i in 1..8
			for n in 1..8
				square_name=[i,n]
				squares[square_name]=nil
			end
		end

		for i in 1..8
			row=2
			square_name=[i,row]
			squares[square_name]=Pawn.new(:w)
			row=7
			square_name=[i,row]
			squares[square_name]=Pawn.new(:b)

		end


		for i in [1,8]

			row=1
			square_name=[i,row]
			squares[square_name]=Rook.new(:w)
			row=8
			square_name=[i,row]
			squares[square_name]=Rook.new(:b)
		end

		for i in [2,7]

			row=1
			square_name=[i,row]
			squares[square_name]=Knight.new(:w)
			row=8
			square_name=[i,row]
			squares[square_name]=Knight.new(:b)
		end

		for i in [3,6]

			row=1
			square_name=[i,row]
			squares[square_name]=Bishop.new(:w)
			row=8
			square_name=[i,row]
			squares[square_name]=Bishop.new(:b)
		end

		squares[[5,1]]=King.new(:w)
		squares[[5,8]]=King.new(:b)
		squares[[4,1]]=Queen.new(:w)
		squares[[4,8]]=Queen.new(:b)


	end

	def display_board
		print "   "
		for j in 'A'..'H'
			print "  "+j+"   "
		end
		print "\n"

		print " "*2+"\u2581"*48+"\n"

		switch=1		
		(1..8).reverse_each do |i|
			print " \u2595"


			for n in 1..8
				if switch==1
					square_color=" "
				else
					square_color="\u2592"
				end
				print square_color*6
				switch=-1*switch
			end
			print "\u258F"
			puts ""


			print i.to_s+"\u2595"
			content=""
			for n in 1..8
				if switch==1
					square_color=" "
				else
					square_color="\u2592"
				end
				if @squares[[n,i]].nil?
					content=square_color+square_color
				else
					content=@squares[[n,i]].character+" "
				end
				print square_color*2+content+square_color*2
				switch=-1*switch
			end
			print "\u258F"
			print i.to_s
			puts ""
			print " \u2595"


			for n in 1..8
				if switch==1
					square_color=" "
				else
					square_color="\u2592"
				end
				print square_color*6
				switch=-1*switch
			end
			switch=-1*switch
			print "\u258F"
			puts ""

		end

		print " "*2+"\u2594"*48+"\n"

		print "   "
		for j in 'A'..'H'
			print "  "+j+"   "
		end
		print "\n"


	end


	def test_move_for_self_check(origin, target, square_hash=@squares)
		square_hash_copy={}

		square_hash.each do |k,v|
			square_hash_copy[k]=v
		end

		

		square_hash_copy[target]=square_hash_copy[origin]
		square_hash_copy[origin]=nil

		if castle?(origin, target)
			#if the king is trying to castle, make sure he's not in check
			#The king can't castle if he's in check
			if self_check?(@squares)
				return true
			end
			castle_hash_copy1={}
			castle_hash_copy2={}
			square_hash.each do |k,v|
				castle_hash_copy1[k]=v
				castle_hash_copy2[k]=v
			end

			#we created two copies of the board, one where the king moved the first square towards castling
			#and another where the king took the second square

			if target[0]>origin[0]
				castle_hash_copy1[[origin[0]+1, origin[1]]]=castle_hash_copy1[origin]
				castle_hash_copy1[origin]=nil
				castle_hash_copy2[[origin[0]+2, origin[1]]]=castle_hash_copy2[origin]
				castle_hash_copy2[origin]=nil
			else
				castle_hash_copy1[[origin[0]-1, origin[1]]]=castle_hash_copy1[origin]
				castle_hash_copy1[origin]=nil
				castle_hash_copy2[[origin[0]-2, origin[1]]]=castle_hash_copy2[origin]
				castle_hash_copy2[origin]=nil
			end

			#if either square is under attack, or would put the king in check, the game will not allow it as a valid move
			if self_check?(castle_hash_copy1) || self_check?(castle_hash_copy2)
				return true
			end
		end

		#We have the copy of the board execute the attempted move. Then we see if that move will put the user in check
		return self_check?(square_hash_copy)
	end


	def place_piece(square, piece)
		@squares[square]=piece
	end

	def self_check?(square_hash=@squares)

		
		self_color=@current_player.color

		king_hash=square_hash.select {|k,v| v != nil && v.instance_of?(King) && v.color==self_color}
		king_square=king_hash.keys[0]


		check=false

		square_hash.each do |k,v|
			if v != nil
				if v.color != self_color

					moves=v.valid_moves(k, square_hash)
					if moves.include?(king_square)
						check=true
					end
				end
			end
		end

		return check

	end

	def self_checkmate?

		
		square_hash_copy={}

		@squares.each do |k,v|
			square_hash_copy[k]=v
		end

		self_pieces_hash=square_hash_copy.select {|k,v| v != nil && v.color==@current_player.color}

		self_pieces_hash.each do |k,v|
			moves= v.valid_moves(k, @squares)
			moves.each do |i|
				if !test_move_for_self_check(k, i)
					return false
				end
			end
		end
		
		return true

	end

	def opponent_check?
		if @current_player.color== :b
			opponent_color = :w
		else
			opponent_color = :b
		end

		#To see if the opponent is in check, first we find the king of the opposing color
		king_hash=@squares.select {|k,v| v != nil && v.instance_of?(King) && v.color==opponent_color}
		king_square=king_hash.keys[0]
		check=false

		#Then we iterate through the squares on the board to find the current player's pieces.
		#We see if their legal moves could capture the king. If the king's square is in their
		#possible movements list, we return true.
		@squares.each do |k,v|
			if v != nil
				if v.color != opponent_color

					moves=v.valid_moves(k, @squares)
					if moves.include?(king_square)
						check=true
					end
				end
			end
		end
		return check
	end

	def convert_to_number(string)

		string[0]=string[0].upcase
		case string[0]
		when 'A'
			column=1
		when 'B'
			column=2
		when 'C'
			column=3
		when 'D'
			column=4
		when 'E'
			column=5
		when 'F'
			column=6
		when 'G'
			column=7
		when 'H'
			column=8
		end

		row=string[1].to_i
		square=[column, row]
		return square
	end

	def sanitize_origin(input)
		if !input.instance_of?(String)
			puts "not a string"
			return false
		end
		if input.size !=2
			puts "size is too big"
			return false
		end


		if !('A'..'H').include?(input[0]) && !('a'..'h').include?(input[0])
			puts "no right letters"
			return false
		end 

		if !('1'..'8').include?(input[1])
			puts "number not in range"
			return false
		end

		origin=convert_to_number(input)
		if @squares[origin]==nil || @squares[origin].color != current_player.color
			puts "That isn't a piece that belongs to you"
			return false
		end


		return true

	end

	def valid_target?(origin, target)
		origin=convert_to_number(origin)
		target=convert_to_number(target)
		unless @squares[origin].valid_moves(origin, @squares).include?(target)
			puts "not a valid target"
			return false
		end
		return true
	end

	def sanitize_input(input)
		input_array=input.scan(/\w+/)
		unless input_array.size==2
			puts "You did not enter two squares."
			return false
		end
		unless sanitize_origin(input_array[0])
			return false
		end

		unless valid_target?(input_array[0],input_array[1])
			return false
		end



		return true
	end

	def convert_input(input)
		input_array=input.scan(/\w+/)
		origin=convert_to_number(input_array[0])
		target=convert_to_number(input_array[1])
		input_array=[]
		input_array << origin
		input_array << target
		return input_array
	end

	def move_piece(input)
		input_array=input
		origin=input_array[0]
		target=input_array[1]

		#check for double_move. If yes, gains en_passant_target
		if pawn_double_move?(origin, target)
			@squares[origin].en_passant_target= true
		end

		#If a pawn is executing en passant, here we destroy the pawn it passes
		if en_passant_move?(origin, target)
			en_passant_victim=@squares.select {|k,v| v.instance_of?(Pawn) && v.en_passant_target==true}
			en_passant_victim.each do |k,v|
				@squares[k]=nil
			end
		end

		#if the king is castling, we also have to move the rook
		if castle?(origin, target)
			rook_square=[]

			#king is moving left
			if origin[0]>target[0]

				@squares.each do |k,v| 
					if k[0]<origin[0] && v.instance_of?(Rook) && v.color==@current_player.color
						rook_square=k
					end
				end

				@squares[[target[0]+1,target[1]]]=@squares[rook_square]
				@squares[rook_square]=nil

			#king is moving right
			else
				@squares.each do |k,v| 
					if k[0]>origin[0] && v.instance_of?(Rook) && v.color==@current_player.color
						rook_square=k
					end
				end

				@squares[[target[0]-1,target[1]]]=@squares[rook_square]
				@squares[rook_square]=nil
			end
		end

		@squares[target]=@squares[origin]
		@squares[origin]=nil

		#if a rook or king moves, it is no longer eligible to castle
		if @squares[target].instance_of?(Rook) || @squares[target].instance_of?(King)
			@squares[target].castle_eligibility= false
		end
		
	end

	def pawn_double_move?(origin, target)
		if @squares[origin].instance_of?(Pawn)
			if @squares[origin].color==:w && origin[1]==2 && target[1]==4
				return true
			elsif @squares[origin].color==:b && origin[1]==7 && target[1]==5
				return true
			end
		end
		return false
	end

	def en_passant_move?(origin, target)

		#If a pawn is executing a legal move to somewhere outside of its own column but into an unoccupied square
		#we know that the movement is an en passant
		if @squares[origin].instance_of?(Pawn) && origin[0] != target[0] && @squares[target]==nil
			return true
		end
		return false

	end

	def castle? (origin, target)
		#If the king is attempting a legal move two columns away from its starting position, we know it is 
		#attempting to castle
		if @squares[origin].instance_of?(King) && (origin[0]==target[0]-2 || origin[0]==target[0]+2)
			return true
		end
		return false
	end

	def valid_input?(input)

		if input.upcase=="SAVE"
			puts "Enter a name for your game"
			filename=gets.chomp
			while filename.match(/\W/)
				puts "Only use letters from the English alphabet for the name. Enter a new name"
				filename=gets.chomp
			end
			puts "Your file was saved as '#{filename}'"
			filename="saved_games/"+filename
			save_game(filename)			
			return false
		end

		unless sanitize_input(input)
			puts "You did not enter a valid input.  "
			return false
		end


		input_array=convert_input(input)
		if test_move_for_self_check(input_array[0], input_array[1])
			puts "That move would put yourself in check.  "
			return false
		end
		return true
	end

	def game_over?
		if opponent_check?
			#if opponent_check_mate (basically go through and check all of oppoenents possible moves. if they all return true for self check, then checkmate is true)
			puts "#{@players[1]} is in check"
		end

		if self_check?
			if self_checkmate?
				puts "Checkmate! #{@players[1]} wins!"
				return true
			else
				puts "#{@players[0]} is in check"
			end
		end

		if draw?
			puts "It is a stalemate! Game over."
			return true
		end

		return false

	end

	def draw?
		#If neither player is in check we see if there is a stalemate.
		if !self_check? && !opponent_check?
			
			#Get all of current player's pieces. Check for valid moves. If there's at least one, we return false
			self_color=@current_player.color
			self_pieces_hash=@squares.select {|k,v| v != nil && v.color==self_color}
			self_pieces_hash.each do |k,v|
				moves=v.valid_moves(k, @squares)
				moves.each do |i|
					if !test_move_for_self_check(k, i)
						return false
					end
				end
			end
			return true
		end

		return false
	end


	def pawn_promotion
		#If a pawn is at the opposite end of the board from where they started, they are promoted to a queen
		pawn_hash=@squares.select {|k,v| (k[1]==1 && v.instance_of?(Pawn) && v.color==:b) || (k[1]==8 && v.instance_of?(Pawn) && v.color==:w)}
		pawn_hash.each do |k,v|
			@squares[k]=Queen.new(v.color)
			puts "#{@players[0]}'s Pawn was promoted to a Queen"
		end	
	end

	def save_game(filename)
		serialized_board= YAML::dump(self)
		f=File.new(filename, 'w')
		f.puts(serialized_board)
		f.close
	end

	def ai_move

		#The ai finds all of the pieces that belongs to it and puts all of their legal moves into an array
		self_pieces_hash=@squares.select {|k,v| v != nil && v.color==@current_player.color}
		possible_moves=[]

		self_pieces_hash.each do |k,v|
			moves= v.valid_moves(k, @squares)
			moves.each do |i|
				if !test_move_for_self_check(k, i)
					possible_moves << [k,i]
				end
			end
		end
		
		#The ai then selects a legal at random and executes it.
		random_index=rand(0...possible_moves.size)
		chosen_move=possible_moves[random_index]
		puts "\n#{current_player} moved from #{convert_to_chess_notation(chosen_move[0])} to #{convert_to_chess_notation(chosen_move[1])}"
		move_piece(chosen_move)

	end

	def clear_en_passant
		en_passant_targets=@squares.select {|k,v| v.instance_of?(Pawn) && v.color==@current_player.color && v.en_passant_target==true}
		en_passant_targets.each do |k,v|
			v.en_passant_target= false
		end

	end

	def clear_board
		@squares.each do |k,v| 
			@squares[k]=nil
		end
	end

	def convert_to_chess_notation(square)
		letter=""
		case square[0]
		when 1
			letter="A"
		when 2
			letter="B"
		when 3
			letter="C"
		when 4
			letter="D"
		when 5
			letter="E"
		when 6
			letter="F"
		when 7
			letter="G"
		when 8
			letter="H"
		end

		notation=letter+square[1].to_s
		return notation
	end





	def game_start

		puts "To move a piece, enter it's current square name and the square name of where you want to move it"
		puts "For example: b2 b3"
		puts "Enter 'save' to save your game or 'exit' to leave the game at any time"	

		

		loop do
			@current_player=@players[0]
			clear_en_passant
			display_board
			if game_over?
				return true
			end

			if @current_player.human
				print "It is #{current_player}'s turn. \n"

				print "Enter a piece and where you want to move it: "
				input=gets.chomp
				if input.upcase=='EXIT'
					return true
				end
				until valid_input?(input)
					print "Enter a piece and where you want to move it: "
					input=gets.chomp
					if input.upcase=='EXIT'
						return true
					end
				end
				input=convert_input(input)
				move_piece(input)
			else
				ai_move
			end

			
			pawn_promotion


			
			puts ""

			@players.reverse!
			

				
		end




	end




end
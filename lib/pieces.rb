class Piece
	attr_reader :color

	def initialize(color)
		@color=color
	end

	def left(origin, spaces=1)
		target=[origin[0], origin[1]]
		spaces.times {target[0]-=1}
		return target
	end

	def right(origin, spaces=1)
		target=[origin[0], origin[1]]
		spaces.times {target[0]+=1}
		return target
	end

	def up(origin, spaces=1)
		target=[origin[0], origin[1]]
		spaces.times {target[1]+=1}
		return target
	end

	def down(origin, spaces=1)
		target=[origin[0], origin[1]]
		spaces.times {target[1]-=1}
		return target
	end

	def up_left(origin, spaces=1)
		target=[origin[0], origin[1]]
		spaces.times {target[0]-=1;target[1]+=1}
		return target
	end

	def up_right(origin, spaces=1)
		target=[origin[0], origin[1]]
		spaces.times {target[0]+=1;target[1]+=1}
		return target
	end

	def down_left(origin, spaces=1)
		target=[origin[0], origin[1]]
		spaces.times {target[0]-=1;target[1]-=1}
		return target
	end

	def down_right(origin, spaces=1)
		target=[origin[0], origin[1]]
		spaces.times {target[0]+=1;target[1]-=1}
		return target
	end




end

class Pawn < Piece
	attr_reader :character
	attr_accessor :en_passant_target

	def initialize(color)
		super
		if @color==:w
			@character="\u2659"
		else
			@character="\u265F"
		end
		@en_passant_target=false
	end



	def valid_moves(origin, squares)
		if @color== :w
			row=1
		else
			row=-1
		end

		moves=[]

		target=[origin[0],origin[1]+row]

		if squares[target]==nil
			moves.push(target)
		end

		#double move

		if @color== :w && origin[1]==2 && squares[up(origin, 2)]==nil && squares[up(origin)]==nil
			moves << up(origin, 2)
		end

		if @color== :b && origin[1]==7 && squares[down(origin, 2)]==nil && squares[down(origin)]==nil
			moves << down(origin, 2)
		end

		#basic capture

		if @color== :w
			left_piece=up_left(origin)
			right_piece=up_right(origin)
		else
			left_piece=down_left(origin)
			right_piece=down_right(origin)
		end

		if left_piece[0]>0 && left_piece[0]<9 && squares[left_piece]!=nil
			if squares[left_piece].color != @color
				moves << left_piece
			end
		end

		if right_piece[0]>0 && right_piece[0]<9 && squares[right_piece]!=nil
			if squares[right_piece].color != @color
				moves << right_piece
			end
		end

		#en_passant

		if squares[left(origin)].instance_of?(Pawn) && squares[left(origin)].en_passant_target==true
			if @color==:w
				moves << up_left(origin)
			else
				moves << down_left(origin)
			end
		end

		if squares[right(origin)].instance_of?(Pawn) && squares[right(origin)].en_passant_target==true
			if @color==:w
				moves << up_right(origin)
			else
				moves << down_right(origin)
			end
		end

		return moves
	end



end

class Rook < Piece
	attr_reader :character
	attr_accessor :castle_eligibility

	def initialize(color)
		super
		if @color==:w
			@character="\u2656"
		else
			@character="\u265C"
		end
		@castle_eligibility=true
	end




	def valid_moves(origin, squares)


		moves=[]

		#going to do the rook moves in 4 chunks, up/down/left/right
		
		end_of_the_line=false

		target=up(origin)
		while target[1]<9 && target[1]>0 && !end_of_the_line do
			
			if squares[target]==nil
				moves << target
			else
				if squares[target].color != @color
					moves << target
				end
				end_of_the_line=true
			end
			target=up(target)
		end


		
		end_of_the_line=false

		target=down(origin)
		while target[1]<9 && target[1]>0 && !end_of_the_line do
			
			if squares[target]==nil
				moves << target
			else
				if squares[target].color != @color
					moves << target
				end
				end_of_the_line=true
			end
			target=down(target)
		end



		


		end_of_the_line=false
		target=left(origin)
		while target[0]<9 && target[0]>0 && !end_of_the_line do
			
			if squares[target]==nil
				moves << target
			else
				if squares[target].color != @color
					moves << target
				end
				end_of_the_line=true
			end
			target=left(target)
		end

		
		end_of_the_line=false
		target=right(origin)
		while target[0]<9 && target[0]>0 && !end_of_the_line do
			
			if squares[target]==nil
				moves << target
			else
				if squares[target].color != @color
					moves << target
				end
				end_of_the_line=true
			end
			target=right(target)
		end





				



		return moves
	end

end

class Knight < Piece
	attr_reader :character

	def initialize(color)
		super
		if @color==:w
			@character="\u2658"
		else
			@character="\u265E"
		end
	end

	def valid_moves(origin, squares)
		moves=[]

		target=[origin[0],origin[1]]

		#The knight has 8 possible moves and it doesn't matter if there are pieces in the way

		possible_moves=[[origin[0]+2,origin[1]+1], [origin[0]+2,origin[1]-1], [origin[0]-2,origin[1]+1], [origin[0]-2,origin[1]-1], [origin[0]+1,origin[1]+2], [origin[0]+1,origin[1]-2], [origin[0]-1,origin[1]+2], [origin[0]-1,origin[1]-2]]

		possible_moves.each do |i|
			if i[0]<9 && i[0]>0 && i[1]>0 && i[1]<9
				if squares[i] !=nil
					if squares[i].color != @color
						moves << i
					end
				else
					moves << i
				end
			end
		end


		return moves
	end

end

class Bishop < Piece
	attr_reader :character

	def initialize(color)
		super
		if @color==:w
			@character="\u2657"
		else
			@character="\u265D"
		end
	end

	def valid_moves(origin, squares)


		moves=[]

		#Check bishop possible movement in 4 directions: slant upleft, upright, downleft, downright
		
		end_of_the_line=false

		target=up_right(origin)
		while target[1]<9 && target[1]>0 && target[0]<9 && target[0]>0 && !end_of_the_line do
			
			if squares[target]==nil
				moves << target
			else
				if squares[target].color != @color
					moves << target
				end
				end_of_the_line=true
			end
			target=up_right(target)
		end


		
		end_of_the_line=false

		target=down_left(origin)
		while target[1]<9 && target[1]>0 && target[0]<9 && target[0]>0 && !end_of_the_line do
			
			if squares[target]==nil
				moves << target
			else
				if squares[target].color != @color
					moves << target
				end
				end_of_the_line=true
			end
			target=down_left(target)
		end



		end_of_the_line=false
		target=down_right(origin)
		while target[1]<9 && target[1]>0 && target[0]<9 && target[0]>0 && !end_of_the_line do
			
			if squares[target]==nil
				moves << target
			else
				if squares[target].color != @color
					moves << target
				end
				end_of_the_line=true
			end
			target=down_right(target)
		end

		end_of_the_line=false
		target=up_left(origin)
		while target[1]<9 && target[1]>0 && target[0]<9 && target[0]>0 && !end_of_the_line do
			
			if squares[target]==nil
				moves << target
			else
				if squares[target].color != @color
					moves << target
				end
				end_of_the_line=true
			end
			target=up_left(target)
		end







		return moves
	end



end

class Queen < Piece
	attr_reader :character

	def initialize(color)
		super
		if @color==:w
			@character="\u2655"
		else
			@character="\u265B"
		end
	end

	def valid_moves(origin, squares)


		

		#Check Queen possible movement in 8 directions: slant upleft, upright, downleft, downright, then left, right, up, down
		#We can just find the Queen's moves by checking all the possible moves of a rook of her color and combine them with the
		#possible moves of a bishop of her color
		
		rook_piece=Rook.new(@color)
		rook_moves=rook_piece.valid_moves(origin, squares)


		bishop_piece=Bishop.new(@color)
		bishop_moves=bishop_piece.valid_moves(origin, squares)


		moves=rook_moves+bishop_moves






		return moves
	end

end

class King < Piece
	attr_reader :character
	attr_accessor :castle_eligibility

	def initialize(color)
		super
		if @color==:w
			@character="\u2654"
		else
			@character="\u265A"
		end
		@castle_eligibility=true
	end

	def valid_moves(origin, squares)
		moves=[]

		#The king can move one square in eight directions

		possible_moves=[up(origin), down(origin), left(origin), right(origin), up_left(origin), down_left(origin), up_right(origin), down_right(origin)]

		possible_moves.each do |i|
			if i[0]<9 && i[0]>0 && i[1]>0 && i[1]<9
				if squares[i] !=nil
					if squares[i].color != @color
						moves << i
					end
				else
					moves << i
				end
			end
		end

		#castle in right direction

		clear_path=true
		next_square=right(origin)
		next_piece=squares[next_square]
		found_rook=false
		if @castle_eligibility==true

			while clear_path==true && found_rook==false && next_square[0]<9
				if next_piece==nil
					next_square=right(next_square)
					next_piece=squares[next_square]
				elsif(next_piece.instance_of?(Rook) && next_piece.color==@color && next_piece.castle_eligibility==true)
					clear_path=false
					found_rook=true
				else
					clear_path=false
				end
			end

			if found_rook==true
				moves << right(origin, 2)
			end
		end

		#castle in left direction

		clear_path=true
		next_square=left(origin)
		next_piece=squares[next_square]
		found_rook=false
		if @castle_eligibility==true
			while clear_path==true && found_rook==false && next_square[0]>0
				if next_piece==nil
					next_square=left(next_square)
					next_piece=squares[next_square]
				elsif(next_piece.instance_of?(Rook) && next_piece.color==@color && next_piece.castle_eligibility==true)
					clear_path=false
					found_rook=true
				else
					clear_path=false
				end
			end

			if found_rook==true
				moves << left(origin, 2)
			end
		end


		return moves
	end



end
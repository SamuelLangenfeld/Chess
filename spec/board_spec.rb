require 'spec_helper'
require_relative '../lib/board.rb'

describe "Board" do
	let(:board) do
		Board.new
	end

	

	describe "initialize" do
		it "sets up a board with 64 squares" do
			expect(board.squares.size).to eql(64)
		end

		it "uses 16 black pieces" do
			black_pieces=board.squares.select {|k,v| v !=nil && v.color==:b}
			expect(black_pieces.size).to eql(16)

		end

		it "uses 16 white pieces" do
			white_pieces=board.squares.select {|k,v| v !=nil && v.color==:w}
			expect(white_pieces.size).to eql(16)
		end

		it "has 16 pawns" do
			pawns=board.squares.select {|k,v| v.instance_of? Pawn}
			expect(pawns.size).to eql(16)
		end

		it "has 4 rooks" do
			rooks=board.squares.select {|k,v| v.instance_of? Rook}
			expect(rooks.size).to eql(4)
		end

		it "has 4 knights" do
			knights=board.squares.select {|k,v| v.instance_of? Knight}
			expect(knights.size).to eql(4)
		end

		it "has 4 bishops" do
			bishops=board.squares.select {|k,v| v.instance_of? Bishop}
			expect(bishops.size).to eql(4)
		end

		it "has 2 queens" do
			queens=board.squares.select {|k,v| v.instance_of? Queen}
			expect(queens.size).to eql(2)			
		end

		it "has 2 kings" do
			kings=board.squares.select {|k,v| v.instance_of? King}
			expect(kings.size).to eql(2)	
		end

	end

	describe "clear_board" do
		it "removes all pieces" do
			board.clear_board
			expect(board.squares.all? {|k,v| v==nil}).to eql(true)
		end
	end

	describe "valid_input?" do

		context "input is entered that does not fit the chess notation" do
			it "returns false" do
				expect(board.valid_input?("move c2 to c4")).to eql(false)
			end
		end

		context "a valid move is entered" do
			it "returns true" do
				expect(board.valid_input?("c2 c3")).to eql(true)
			end
		end

		context "a player tries to move off the board" do
			it "returns false" do
				expect(board.valid_input?("a1 a0")).to eql(false)
			end
		end

		context "a move is entered that does not fit the piece's movement" do
			it "returns false" do
				expect(board.valid_input?("a2 a6")).to eql(false)
			end
		end

		context "a piece tries to move into the space of another piece of its own color" do
			it "returns false" do
				expect(board.valid_input?("a1 b1")).to eql(false)
			end
		end

		context "a piece does a valid move into an enemy's square" do
			it "returns true" do
				board.squares[[2,3]]=Pawn.new(:b)
				expect(board.valid_input?("a2 b3")).to eql(true)
			end
		end

		context "if a move would put the current player in check" do
			it "returns false" do
				board.clear_board
				board.squares[[1,1]]=King.new(:w)
				board.squares[[2,2]]=Rook.new(:b)
				expect(board.valid_input?("a1 b1")).to eql(false)
			end
		end

		context "a player tries to move another player's piece" do
			it "returns false" do
				board.players.reverse!
				board.current_player=board.players[0]
				expect(board.valid_input?("a2 a4")).to eql(false)
			end
		end

		context "A pawn does double move" do
			it "returns true" do
				expect(board.valid_input?("a2 a4")).to eql(true)
			end
		end

		context "A pawn attempts en passant against a valid target" do
			it "returns true" do
				board.clear_board
				board.squares[[1,5]]=Pawn.new(:w)
				board.squares[[2,5]]=Pawn.new(:b)
				board.squares[[2,5]].en_passant_target=true
				expect(board.valid_input?("a5 b6")).to eql(true)
			end
		end

		context "A pawn attempts en passant against an invalid target" do
			it "returns true" do
				board.clear_board
				board.squares[[1,5]]=Pawn.new(:w)
				board.squares[[2,5]]=Pawn.new(:b)
				expect(board.valid_input?("a5 b6")).to eql(false)
			end
		end

		context "A king moves to castle" do
			it "returns true" do
				board.clear_board
				board.squares[[5,1]]=King.new(:w)
				board.squares[[1,1]]=Rook.new(:w)
				expect(board.valid_input?("e1 c1")).to eql(true)
			end
		end

		context "A king moves to castle through a square that's under enemy attack" do
			it "returns false" do
				board.clear_board
				board.squares[[5,1]]=King.new(:w)
				board.squares[[1,1]]=Rook.new(:w)
				board.squares[[5,2]]=Bishop.new(:b)
				expect(board.valid_input?("e1 c1")).to eql(false)
			end
		end

		context "A king moves to castle through an occupied square" do
			it "returns false" do
				board.clear_board
				board.squares[[5,1]]=King.new(:w)
				board.squares[[2,1]]=Knight.new(:w)
				board.squares[[1,1]]=Rook.new(:w)
				expect(board.valid_input?("e1 c1")).to eql(false)
			end
		end


	end


	describe "castle?" do

		context "If a player is attempting to castle" do
			it "returns true" do
				board.clear_board
				board.squares[[5,1]]=King.new(:w)
				board.squares[[1,1]]=Rook.new(:w)
				expect(board.castle?([5,1],[3,1])).to eql(true)
			end
		end

		context "A king is doing a regular move" do
			it "returns false" do
				board.clear_board
				board.squares[[5,1]]=King.new(:w)
				board.squares[[1,1]]=Rook.new(:w)
				expect(board.castle?([5,1],[4,1])).to eql(false)
			end
		end

	end


	describe "draw?" do
		context "If a player is not in check, but has no legal moves" do
			it "returns true" do
				board.clear_board
				board.squares[[5,1]]=King.new(:w)
				board.squares[[6,3]]=King.new(:b)
				board.squares[[4,3]]=Queen.new(:b)
				expect(board.draw?).to eql(true)
			end
		end

		context "If there are still remaining moves" do
			it "returns false" do
				expect(board.draw?).to eql(false)
			end
		end
	end

	describe "opponent_check?" do

		context "if your opponent is in check" do
			it "returns true" do
				board.clear_board
				board.squares[[2,1]]=Rook.new(:w)
				board.squares[[1,1]]=King.new(:b)
				expect(board.opponent_check?).to eql(true)
			end
		end

		context "if your opponent is not in check" do
			it "returns false" do
				expect(board.opponent_check?).to eql(false)
			end
		end
	end

	describe "self_check?" do
		context "if you are in check" do
			it "returns true" do
				board.clear_board
				board.squares[[2,1]]=Rook.new(:b)
				board.squares[[1,1]]=King.new(:w)
				expect(board.self_check?).to eql(true)
			end
		end

		context "if you are not in check" do
			it "returns false" do
				expect(board.self_check?).to eql(false)
			end
		end
	end

	describe "self_checkmate?" do
		context "if you are in checkmate" do
			it "returns true" do
				board.clear_board
				board.squares[[6,2]]=Rook.new(:b)
				board.squares[[7,1]]=Queen.new(:b)
				board.squares[[5,1]]=King.new(:w)
				expect(board.self_checkmate?).to eql(true)
			end
		end

		context "if you are not in checkmate" do
			it "returns false" do
				expect(board.self_checkmate?).to eql(false)
			end
		end
	end



	describe "game_over?" do

		context "If there is a stalemate" do
			it "returns true" do
				board.clear_board
				board.squares[[5,1]]=King.new(:w)
				board.squares[[6,3]]=King.new(:b)
				board.squares[[4,3]]=Queen.new(:b)
				expect(board.game_over?).to eql(true)
			end
		end

		context "if a player is in checkmate" do
			it "returns true" do
				board.clear_board
				board.squares[[6,2]]=Rook.new(:b)
				board.squares[[7,1]]=Queen.new(:b)
				board.squares[[5,1]]=King.new(:w)
				expect(board.game_over?).to eql(true)
			end
		end

		context "if there is no stalemate or checkmate" do
			it "returns false" do
				expect(board.game_over?).to eql(false)
			end
		end

	end


	describe "pawn_promotion" do
		context "if a pawn reaches the opposite end of the board" do
			it "becomes a queen" do
				board.clear_board
				board.squares[[1,8]]=Pawn.new(:w)
				board.squares[[1,1]]=Pawn.new(:b)
				board.pawn_promotion
				expect(board.squares[[1,8]].instance_of? Queen).to eql(true)
				expect(board.squares[[1,1]].instance_of? Queen).to eql(true)
			end
		end

		context "a pawn not at the end of the board will stay a pawn" do
			it do
				board.clear_board
				board.squares[[1,2]]=Pawn.new(:w)
				board.pawn_promotion
				expect(board.squares[[1,2]].instance_of? Pawn).to eql(true)
			end
		end
	end

	describe "move_piece" do
		context "a pawn does a double move" do
			it "becomes an en passant target" do
				board.move_piece([[1,2],[1,4]])
				expect(board.squares[[1,4]].en_passant_target).to eql(true)
			end
		end

		context "if a piece moves" do
			it "occupies the target square, while leaving the previous square empty" do
				board.move_piece([[1,2],[1,3]])
				expect(board.squares[[1,2]].nil?).to eql(true)
				expect(board.squares[[1,3]].instance_of? Pawn).to eql(true)
			end
		end

		context "if a pawn uses en passant" do
			it "eliminates the passed pawn" do
				board.clear_board
				board.squares[[1,5]]=Pawn.new(:w)
				board.squares[[2,5]]=Pawn.new(:b)
				board.squares[[2,5]].en_passant_target=true
				board.move_piece([[1,5],[2,6]])
				expect(board.squares[[2,5]].nil?).to eql(true)
			end
		end

		context "a king castles" do
			it "the king moves 2 spaces closer to the rook and the rook moves to the other side of the king" do
				board.clear_board
				board.squares[[5,1]]=King.new(:w)
				board.squares[[1,1]]=Rook.new(:w)
				board.move_piece([[5,1],[3,1]])
				expect(board.squares[[3,1]].instance_of? King).to eql(true)
				expect(board.squares[[4,1]].instance_of? Rook).to eql(true)
			end
		end	

	end





end
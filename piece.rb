class Piece
	attr_accessor :color
	def initialize(color)
		@color = color
	end

	def is_jump_move?(from, to)
  		(from[0] - to[0]).abs == 2 && (from[1] - to[1]).abs == 2
	end

	def is_single_move?(from, to)
  		(from[0] - to[0]).abs == 1 && (from[1] - to[1]).abs == 1
	end

	def valid_single_move?(board, from, to)
		is_right_direction?(from, to) && is_single_move?(from, to) && board[to].nil?
	end

	def is_right_direction?(from, to)
		@color == :white ? (from[0] - to[0]) > 0 : (from[0] - to[0]) < 0
	end

	def pieces_between(board, from, to)
		pieces_between = []
		Board.points_between(from, to).each do |point|
			pieces_between << board[point] if board[point]
		end
		pieces_between
	end

	def valid_jump_move?(board, from, to)
		if is_jump_move?(from, to) && board[to].nil? && 
			(backwards_capture || is_right_direction?(from, to))
			pieces_between = pieces_between(board, from, to)
			pieces_between.length == 1 && pieces_between.first.color != self.color
  		else
  			false
		end
	end
end

class Men < Piece
	@@backwards_capture = false
	
	def self.set_backwards_capture(backwards_capture)
		@@backwards_capture = backwards_capture
	end

  	def can_do_move?(board, from, to)
		valid_single_move?(board, from, to) || valid_jump_move?(board, from, to)
  	end

  	def backwards_capture
  		@@backwards_capture
	end
end

class King < Piece
	@@long_range = false

	def self.promote(men)
		King.new(men.color)
	end

	def self.set_long_range(long_range)
		@@long_range = long_range
	end

	def is_jump_move?(from, to)
		if @@long_range
  			(from[0] - to[0]).abs == (from[1] - to[1]).abs && (from[1] - to[1]).abs > 1
  		else
  			super(from, to)
  		end
	end

	def can_do_move?(board, from, to)
		valid_single_move?(board, from, to) || valid_jump_move?(board, from, to)
	end

	def is_right_direction?(from, to)
		true
	end

	def backwards_capture
		true
	end
end
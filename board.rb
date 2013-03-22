require 'colorize'

class InvalidMoveError < RuntimeError
end

class Board
	
	def initialize(rules)
		@rows = Array.new(rules[:board_size]) { Array.new(rules[:board_size]) { nil } }
		Men.set_backwards_capture(rules[:men_backwards_capture])
		King.set_long_range(rules[:long_range_kings])
		@counts = Hash.new(rules[:pieces_per_side])
		@compulsory_capture = rules[:compulsory_capture]
		fill_pieces(rules[:pieces_per_side])
	end

	def fill_pieces(pieces_per_side)
		w_row, w_col = @rows.length - 1, 0
		b_row, b_col = 0, @rows.length - 1
		offset = 0
		pieces_per_side.times do
			self[[w_row, w_col + offset]] = Men.new(:white)
			self[[b_row, b_col - offset]] = Men.new(:black)
			w_col += 2
			b_col -= 2
			if w_col + offset >= @rows.length
				w_row, w_col = w_row - 1, 0 
				b_row, b_col = b_row + 1, @rows.length - 1
				offset = 1 - offset
			end
		end
	end

	def at_far_end_of_board?(coord)
		return false unless self[coord]
		color = self[coord].color
		(coord[0] == 0 && color == :white) || (coord[0] == @rows.length - 1 && color == :black)
	end

	def game_over?
		@counts.values.include?(0) 
	end

	def winner
		if @counts[:black] == 0
			:white
		elsif @counts[:white] == 0
			:black
		else
			nil
		end
	end

	def stalemate?(color)
		!has_possible_moves(color)
	end

	def has_capture_move?(from)
		return false if from.nil? || self[from].nil?
		all_moveable_coords.each do |to|
			next unless self[from].is_jump_move?(from, to)
			return true if self[from].can_do_move?(self, from, to)
		end
		false
	end

	def valid_from?(player_color, from)
		is_moveable_block?(from) && self[from] && self[from].color == player_color
	end

	def valid_to?(to)
		is_moveable_block?(to) && self[to].nil?
	end

	def valid_move?(player_color, from, to)
		if valid_from?(player_color, from) && valid_to?(to) && from != to
			if !@compulsory_capture || all_capture_froms(player_color).empty?
				self[from].can_do_move?(self, from, to)
			else
				unless all_capture_froms(player_color).include?(from) && self[from].is_jump_move?(from, to)

					return false 
				end
				self[from].can_do_move?(self, from, to)
			end
		else
			false
		end
	end

	def all_capture_froms(player_color)
		all_piece_coords(player_color).select { |coord| has_capture_move?(coord) }
	end

	def all_piece_coords(color)
		all_piece_coords = []
		all_moveable_coords.each do |coord|
			next if self[coord].nil? || self[coord].color != color
			all_piece_coords << coord 
		end
		all_piece_coords
	end

	def has_possible_moves(color)
		all_piece_coords(color).each do |from|
			all_moveable_coords.each do |to|
				return true if self[from].can_do_move?(self, from, to)
			end
		end
		false
	end

	def all_possible_moves(color)
		all_possible_moves = {}
		all_piece_coords(color).each do |from|
			piece = self[from]
			moves = []
			all_moveable_coords.each do |to|
				moves << to if piece.can_do_move?(self, from, to)
			end
			all_possible_moves[from] = moves unless moves.empty?
		end
		all_possible_moves
	end


	def all_moveable_coords
		all_moveable_coords = []
		@rows.each_with_index do |row, i|
			row.each_with_index do |p, j|
				all_moveable_coords << [i,j] if is_moveable_block?([i ,j]) 
			end
		end
		all_moveable_coords
	end

	def make_move(player_color, from, to)
		raise InvalidMoveError.new unless valid_move?(player_color, from, to)
		moving_coord = nil
		if self[from].is_jump_move?(from, to)
			Board.points_between(from, to).each do |point|
				next if self[point].nil?
				@counts[self[point].color] -= 1
				self[point] = nil
			end
			moving_coord = to
		end
		self[to], self[from] = self[from], nil
		self[to] = King.promote(self[to]) if at_far_end_of_board?(to)
		moving_coord
	end

	def self.points_between(point1, point2)
		[[(point1[0] + point2[0])/2, (point1[1] + point2[1])/2]]
	end

	def is_moveable_block?(coord)
		coord.inject(0) { |sum, e| sum + e } % 2 == 1
	end

	def pretty_print
		puts "    " + (0...@rows.length).map { |i| " #{i.to_s.ljust(2)}" }.join
		@rows.each_with_index do |row, i|
			print " #{i.to_s.rjust(2)} "
			row.each_with_index do |piece, j|
				s = case piece
					when nil then '   '
					when King then ' K '
					when Men then ' O '
				end
				background = is_moveable_block?([i ,j]) ? :red : :white
				color = piece.color if piece
				print s.colorize(:color => color, :background => background)
			end
			puts
		end
	end

	def [](coord)
		@rows[coord[0]][coord[1]]
	end

	def []=(coord, value)
		@rows[coord[0]][coord[1]] = value
	end

end
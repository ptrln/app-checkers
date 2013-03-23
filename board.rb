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

	def at_far_end_of_board?(coord)
		return false unless self[coord]
		case [coord[0], self[coord].color]
			when [0, :white] then true
			when [@rows.length - 1, :black] then true
			else false
		end
	end

	def game_over?
		@counts.values.include?(0)
	end

	def winner
		@counts[:black] == 0 ? :white : (@counts[:white] == 0 ? :black : nil)
	end

	def stalemate
		[:white, :black].each do |color|
			return color if no_more_moves?(color)
		end
		nil
	end

	def no_more_moves?(color)
		!has_possible_moves(color)
	end

	def is_capture_move?(from, to)
		self[from].is_jump_move?(from, to) && self[from].can_do_move?(self, from, to)
	end

	def valid_move?(player_color, from, to)
		if valid_from?(player_color, from) && valid_to?(to) && from != to
			capture_froms = all_capture_froms(player_color)
			if capture_move_required?(capture_froms)
				if capture_froms.include?(from) && self[from].is_jump_move?(from, to)
					return self[from].can_do_move?(self, from, to)
				end
			else
				return self[from].can_do_move?(self, from, to)
			end
		end
		false
	end

	def capture_move_required?(capture_froms)
		@compulsory_capture && !capture_froms.empty?
	end

	# returns coord if has another capture move, otherwise nil
	# use return value to determine if current player has another move
	def make_move(player_color, from, to)	
		raise InvalidMoveError.new unless valid_move?(player_color, from, to)
		moving_coord = nil
		if self[from].is_jump_move?(from, to)
			remove_piece_in_path(player_color, from, to)
			moving_coord = to
		end
		self[to], self[from] = self[from], nil
		self[to] = King.promote(self[to]) if at_far_end_of_board?(to)
		moving_coord if has_capture_move?(moving_coord)
	end

	def self.points_between(point1, point2)
		row_delta, col_delta = point1[0] - point2[0], point1[1] - point2[1]
		points_between = []
		point = point1.dup
		while true
			point[0] = point[0] + (row_delta > 0 ? -1 : 1)
			point[1] = point[1] + (col_delta > 0 ? -1 : 1)
			break if point == point2
			points_between << point.dup
		end
		points_between
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

	private
	def remove_piece_in_path(color, from, to)
		pieces = Board.points_between(from, to).select { |point| self[point] }
		raise "No piece in jump path" if pieces.count == 0
		raise "Multiple pieces in jump path" if pieces.count > 1
		raise "Own piece in jump path" if self[pieces.first].color == color
		@counts[self[pieces.first].color] -= 1
		self[pieces.first] = nil
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
	
	def has_capture_move?(from)
		return false if from.nil? || self[from].nil?
		all_moveable_coords.any? { |to| is_capture_move?(from, to) }
	end

	def valid_from?(player_color, from)
		is_moveable_block?(from) && self[from] && self[from].color == player_color
	end

	def valid_to?(to)
		is_moveable_block?(to) && self[to].nil?
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

	def all_moveable_coords
		all_moveable_coords = []
		@rows.each_with_index do |row, i|
			row.each_with_index do |p, j|
				all_moveable_coords << [i,j] if is_moveable_block?([i ,j]) 
			end
		end
		all_moveable_coords
	end

	def is_moveable_block?(coord)
		coord.inject(0) { |sum, e| sum + e } % 2 == 1
	end

	def []=(coord, value)
		@rows[coord[0]][coord[1]] = value
	end

end
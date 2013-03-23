class Player
	attr_accessor :color

	def game_over(board)
		board.pretty_print
		if board.winner
			puts "Game over! #{pretty_color(board.winner)} wins!"
		elsif board.stalemate
			puts "Stalemate! #{pretty_color(board.stalemate)} has no more moves!"
		end
	end

	def opponent_color
		@color == :white ? :black : :white
	end

	def pretty_color(color = @color)
		color.to_s.capitalize
	end
end

class HumanPlayer < Player

	def move(board)
		board.pretty_print
		puts "It's your turn, #{pretty_color}!"
		return get_input("from"), get_input("to")
	end

	def additional_move(board, coord)
		board.pretty_print
		puts "You have an additional move. Moving from #{coord}."
		return get_input("to")
	end

	def get_input(type)
		while true
			print "#{type} (row, col) > "
			input = gets.chomp.split(/[^\d]/)
			if input.length == 2 
				return input.map(&:to_i)
			else 
				puts "Invalid input! Try again..."
			end
		end
	end

	def invalid_move(from, to)
		puts "Invalid move! Try again..."
	end
end

class ComputerPlayer < Player

	def move(board)
		board.pretty_print
		all_pos = board.all_possible_moves(self.color)
		take_move(board, all_pos) || random_move(all_pos)
	end

	def random_move(all_pos, from = nil)
		from = all_pos.keys.sample if from.nil?
		to = all_pos[from].sample
		return from, to
	end

	def take_move(board, all_pos)	#this move takes enemy piece
		all_pos.each do |from, possible_tos|
			possible_tos.each do |to|
				return from, to if board.is_capture_move?(from, to)
			end
		end
		nil
	end

	def additional_move(board, coord)
		board.pretty_print
		all_pos = board.all_possible_moves(self.color)
		take_move(board, {coord => all_pos[coord]}).last || random_move(all_pos, coord).last
	end

	def invalid_move(from, to)
		raise "Computer tried invalid move? #{from} => #{to}"
	end
end

class AdvancedComputerPlayer < ComputerPlayer

	def move(board)
		board.pretty_print
		all_pos = board.all_possible_moves(self.color)
		
		take_move(board, all_pos) || king_move(board, all_pos) || avoidance_move(board, all_pos) || random_move(all_pos)
	end

	def avoidance_move(board, all_pos)	#this move avoids our piece from being taken
		nil
	end

	def king_move(board, all_pos)	#this move makes a king for us
		all_pos.each do |from, possible_tos|
			next if board[from].is_a?(King)
			possible_tos.each do |to|
				return from, to if board.at_far_end_of_board?(to)
			end
		end
		nil
	end

end
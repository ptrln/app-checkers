class Player
	attr_accessor :color

	def game_over(board)
		board.pretty_print
		if board.winner
			puts "Game over! #{board.winner.to_s} wins!"
		else
			puts "#{@color} Stalement! Your opponent has no more moves!"
		end
	end

	def opponent_color
		@color == :white ? :black : :white
	end
end

class HumanPlayer < Player

	def move(board)
		board.pretty_print
		puts "It's your turn, #{@color.to_s.capitalize}!"
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
		from = all_pos.keys.sample
		to = all_pos[from].sample
		return from, to
	end

	def additional_move(board, coord)
		board.pretty_print
		board.all_possible_moves(self.color)[coord].sample
	end

	def invalid_move(from, to)
		#keep making moves until computer hits a valid one
		#raise "Computer tried invalid move? #{from} => #{to}"
	end
end
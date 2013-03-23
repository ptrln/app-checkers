require './checker_variants'
require './board'
require './piece'
require './player'

class CheckersGame
	
	def self.run(player1, player2, variant = :american)
		rules = CheckerVariants.rules_for_variant(variant)
		raise "Variant #{variant} is not supported" if rules.nil?

		board, current_p, next_p = setup(rules, player1, player2)
		chain = nil
		until board.game_over? || board.no_more_moves?(current_p.color)
			from, to = get_player_move(board.dup, current_p, chain)
			begin
				chain = board.make_move(current_p.color, from, to)
				current_p, next_p = next_p, current_p unless chain
			rescue InvalidMoveError
				current_p.invalid_move(from, to)
			end
		end
		next_p.game_over(board)
	end

	def self.get_player_move(board, player, moving_coord)
		if moving_coord.nil?
			return player.move(board.dup)
		else
			return moving_coord, player.additional_move(board.dup, moving_coord)
		end
	end

	def self.setup(rules, player1, player2)
		puts "Rules for #{rules[:name]} Checkers:"
		puts rules
		player1.color = rules[:first_move_color]
		player2.color = rules[:first_move_color] == :black ? :white : :black
		return Board.new(rules), player1, player2
	end

end

CheckersGame.run(AdvancedComputerPlayer.new, ComputerPlayer.new)
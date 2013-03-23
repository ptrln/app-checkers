require './checker_variants'
require './board'
require './piece'
require './player'

class CheckersGame
	
	def self.run(player1, player2, variant = :american)
		rules = CheckerVariants.rules_for_variant(variant)
		raise "Variant #{variant} is not supported" if rules.nil?

		board, player_now, player_next = setup(rules, player1, player2)
		chain = nil
		until board.game_over? || board.no_more_moves?(player_now.color)
			from, to = get_player_move(board.dup, player_now, chain)
			begin
				chain = board.make_move(player_now.color, from, to)
				player_now, player_next = player_next, player_now unless chain
			rescue InvalidMoveError
				player_now.invalid_move(from, to)
			end
		end
		player_next.game_over(board)
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

CheckersGame.run(ComputerPlayer.new, ComputerPlayer.new)
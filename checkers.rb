require './checker_variants'
require './board'
require './piece'
require './player'

class CheckersGame
	include CheckerVariants
	
	def self.run(player1, player2, variant = :american)
		rules = CheckerVariants.rules_for_variant(variant)
		raise "Variant #{variant} is not supported" if rules.nil?

		board, player_now, player_next = setup(rules, player1, player2)
		moving_piece_coord = nil
		until board.game_over? || board.stalemate?(player_now.color)
			if moving_piece_coord.nil?
				from, to = player_now.move(board.dup)
			else
				from, to = moving_piece_coord, player_now.additional_move(board.dup, moving_piece_coord)
			end
			begin
				moving_piece_coord = board.make_move(player_now.color, from, to)
				unless board.has_capture_move?(moving_piece_coord)
					player_now, player_next = player_next, player_now
					moving_piece_coord = nil
				end
			rescue InvalidMoveError
				player_now.invalid_move(from, to)
			end
		end
		player_next.game_over(board)
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
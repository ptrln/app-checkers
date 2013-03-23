class CheckerVariants

	ENGLISH_AND_AMERICAN = {
		:board_size => 8, 
		:pieces_per_side => 12, 
		:first_move_color => :black,
		:long_range_kings => false,
		:men_backwards_capture => false,
		:compulsory_capture => true
	}

	VARIANTS = {
		:international => { 
			:board_size => 10, 
			:pieces_per_side => 20, 
			:first_move_color => :white,
			:long_range_kings => true,
			:men_backwards_capture => true,
			:compulsory_capture => true
		},
		:canadian => { 
			:board_size => 12, 
			:pieces_per_side => 30, 
			:first_move_color => :white,
			:long_range_kings => true,
			:men_backwards_capture => true,
			:compulsory_capture => true
		},
		:spanish => { 
			:board_size => 8, 
			:pieces_per_side => 12, 
			:first_move_color => :white,
			:long_range_kings => true,
			:men_backwards_capture => false,
			:compulsory_capture => true
		},
		:italian => {
			:board_size => 8, 
			:pieces_per_side => 12, 
			:first_move_color => :white,
			:long_range_kings => false,
			:men_backwards_capture => false,
			:compulsory_capture => true
		},
		:english => ENGLISH_AND_AMERICAN,
		:american => ENGLISH_AND_AMERICAN
	}

	def self.rules_for_variant(variant)
		rules = VARIANTS[variant]
		rules[:name] = variant.to_s.capitalize unless rules.nil?
		rules
	end

end
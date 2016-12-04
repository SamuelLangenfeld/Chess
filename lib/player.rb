class Player
	attr_accessor :color
	attr_accessor :name
	attr_accessor :human

	def initialize(name, color, human)
		@name=name
		@color=color
		@human=human
	end

	def to_s
		return @name
	end


end
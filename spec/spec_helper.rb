require "tagen/core"

class Pa
	class << self
		public :_copy, :_move
	end
end

class Dir
	class << self
		def empty? path
			Dir.entries(path).sort == %w(. ..)
		end
	end
end

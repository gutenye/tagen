require "tagen/core"


class Dir
	class << self
		def empty? path
			Dir.entries(path).sort == %w(. ..)
		end
	end
end

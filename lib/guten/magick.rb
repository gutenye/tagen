module Magick
	class Image
		alias width columns
		alias height rows
		def wh; [columns, rows] end
	end
end

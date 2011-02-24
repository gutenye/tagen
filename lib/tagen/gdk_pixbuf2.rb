module Gdk
	class Pixbuf
		# get width, height
		#
		# @return [Array] [width, height]
		def wh; [width.to_f, height.to_f] end

		# get width
		#
		# @return [Float] width
		def w; wh[0] end

		# get height
		#
		# @return [Float] height
		def h; wh[1] end

		# set width, height
		#
		# @param [Array] wh [width, height]
		def wh=(wh) width=wh[0]; height=wh[1] end

		alias w= width=
		alias h= height=
	end
end

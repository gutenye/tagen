module Gdk
	class Pixbuf
		def wh; [width.to_f, height.to_f] end
		def w; wh[0] end
		def h; wh[1] end
		def wh=(wh) width=wh[0]; height=wh[1] end
		alias w= width=
		alias h= height=
	end
end

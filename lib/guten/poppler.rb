
module Poppler 
class Document
	alias npages size
	def wh; self[0].size end
	def w; wh[0] end
	def h; wh[1] end
end # class Document

class Page
	alias wh size
	def w; size[0] end
	def h; size[1] end

	def cairo_context
		require "cairo"
		require_relative "cairo"
		surface = Cairo::ImageSurface.new(*self.wh)
		ctx = Cairo::Context.new(surface)
		render(ctx)
		ctx
	end # def cairo_context
end # class Page

end # module Poppler

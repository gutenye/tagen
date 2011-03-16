require "poppler"
=begin
* **Install**: Ruby-Gnome
=end
module Poppler 

=begin
Additional Method List
---------------------
* \#npages: _alias from size_
=end
class Document
	alias npages size
	# get width height
	def wh; self[0].size end
	# get width
	def w; wh[0] end
	# get height
	def h; wh[1] end
end # class Document

=begin
Additional Method List
----------------------
* \#wh: _alias from size_
=end
class Page
	alias wh size
	# get width
	def w; size[0] end
	# get height
	def h; size[1] end

	# used when 'cairo' is installed
	#
	# @return [Cairo::Context]
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

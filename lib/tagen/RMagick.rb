=begin
* **gem**: rmagic
=end
module Magick

=begin
Method list
-----------
* \#width _alias from columns_
* \#height  _alias from rows_
=end
class Image

	alias width columns
	alias height rows

	# get width height
	#
	# @return [Array] [width, height]
	def wh; [columns, rows] end

end
end

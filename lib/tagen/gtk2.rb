require "cairo"
require_relative "cairo"
require "gtkhtml2"

module Gtk

class Window 
	# alias from set_default_size
	def default_size=(wh)
		set_default_size(*wh)
	end
end # class Window

class ListStore 
	alias append_ append
	# @example
	# 	data=[
	# 		[1, 2],
	# 		[3, 4]
	# 	]
	# 	liststore.append(data)
	def append rows
		rows.each do |row|
			iter = append_
			row.each do |col, col_i|
				iter[col_i] = col
			end
		end
	end
end # class ListStore

=begin
Addition Methods list
---------------------
* \#add _alias from add\_widget_
=end
class SizeGroup 
	alias initialize_ initialize
	# add mode=HORIZONTAL as default option
	def _initialize(mode=HORIZONTAL)
		initialize_(mode)
	end
	alias add add_widget
end # class SizeGroup

class PrintOperation 
	alias initialize_ initialize
	# add @ispreview instance variable
	def initialize
		initialize_

		@ispreview = false
		signal_connect("ready") do |previewop, ctx|
			@ispreview = true
		end
	end

	def preview?; @ispreview end

	alias run_ run 
	def run(action=:print_dialog, parent=nil, &blk)
		action = PrintOperation.const_get("ACTION_#{action}".upcase) 
		if blk
			run_(action, parent){|result| 
				blk.call self,result.nick.gsub(/-/, "_").to_sym
			}
		else
			run_(action, parent)
		end
	end # def run

	alias status_ status
	# return symbol.
	def status
		status_.nick.gsub(/-/,"_").to_sym
	end # def status

end # class PrintOperation

class Entry 
	alias text_ text

	# default encoding is ASCII-8BIT, some error occurs.
	# change to text.force_encoding("UTF-8")
	def text
		text_.force_encoding "UTF-8"
	end
end

end # module Gtk

module Gdk

class EventKey 
	# return {Gdk::Key} instance
	def key
		Key.new keyval
	end

end # class EventKey

class Key 
	attr_reader :code, :name
	def initialize keyval
		@code = keyval
		@name = Keyval.to_name(keyval).downcase.to_sym
	end

	def ==(key)
		case key
		when Integer
			@code == key
		when String,Symbol
			@name == key.to_sym
		end
	end # def ==

	def inspect; @name end

end # class Key
end # module Gdk


# gdk_pixbuf2 for 
# 	Context#set_source
# 		set_source_pixbuf
begin
	require "gdk_pixbuf2"
	require_relative "gdk_pixbuf2"
rescue
end

# confict. Gtk::PrintContext use Cairo. but not use Context#initialize method
# because inherit probleam
# FF1. only change Cairo::Context -> Cairo::Contexg
# FF2. Gtk::PrintContext config with cairo. so change Gtk::PrintContext

=begin
* **Install**: gem(cairo)
=end
module Cairo

	# compute width height by rotate and scale
	def self.compute_wh(w, h, rotate=0,scale=1) #{{{1
	# selection=[x,y,w,h]
		w,h=1,1 if w<=0 or h<=0
		w,h = w*scale.to_f, h*scale.to_f

		radius = 0

		rotate = rotate*180/Math::PI if String===rotate
		rotate %= 360

		unless rotate.zero?
			radius = rotate / 180.0 * Math::PI
			if (90 < rotate and rotate < 180) or (270 < rotate and rotate < 360)
				radius -= Math::PI / 2
			end
		end
		inner_angle1 = Math.atan(w/h)
		inner_angle2 = Math.atan(h/w)
		diagonal = Math.sqrt(w**2 + h**2)

		angle1 = radius + inner_angle1
		angle2 = radius + inner_angle2

		bottom1 = diagonal * Math.cos(angle1)
		length1 = (bottom1 * Math.tan(angle1)).abs.to_up
		bottom2 = diagonal * Math.cos(angle2)
		length2 = (bottom2 * Math.tan(angle2)).abs.to_up

		if (0 <= rotate and rotate <= 90) or (180 <= rotate and rotate <= 270)
			[length1, length2]
		else
			[length2, length1]
		end
	end # def self.compute_wh
end

module Cairo
	# class FontExtents and TextExtents 
	class FontExtents 
		# return \[ascent, descent, height, max_x_advance, max_y_advance\]
		def to_a
			[ascent,descent,height,max_x_advance,max_y_advance]
		end
	end
				
	# Additional Method List
	# ----------------------
	# * \#w: _alias from width_
	# * \#h: _alias from h_
	class TextExtents 
		alias w width
		alias h height

		# get width, height
		def wh; [width, height] end
		# get \[x_advance, y_advance\]
		def xy_advance; [x_advance, y_advance] end
		# get [x_bearing, y_bearing\]
		def xy_bearing; [x_bearing, y_bearing] end
	
		# get \[x_bearing, y_bearing, width, height, x_advance, y_advance\]
		def to_a
			[x_bearing, y_bearing, width, height, x_advance, y_advance]
		end
	end

	class PDFSurface 
		alias initialize_ initialize
		def initialize(filename, width, height)
			initialize_(filename, width, height)
			@wh=[width.to_f, height.to_f]
		end

		# get width, height
		def wh; @wh end
		# get width
		def w; @wh[0] end
		# get height
		def h; @wh[1] end
	end # class PDFSurface

	class ImageSurface 
		alias initialize_ initialize

		# get width, height
		def wh; [width.to_f, height.to_f] end
		# get width
		def w; self.wh[0] end
		# get height
		def h; self.wh[1] end

	end # class ImageSurface

	class Context 
	private 
		# utils 
		def __rpos(*args)
		# 10   user_relative_distance 
		# "10" device_relative_distance
			x_,y_ = xy
			args.split(2,[]) do |(x,y),i,memo|
				x = String===x ? tdu(x.to_f)      : x
				y = String===y ? tdu(nil, y.to_f) : y
				memo.push(x+x_, y+y_)
			end
		end
		def __tpos(*args)
		# 7 device_relative_distance
			x_, y_ = xy
			args.split(2, []) do |(x,y), i, memo|
				x,y = tdu(x, y)	
				memo.push(x+x_, y+y_)
			end
		end

		def __dpos(*args)
		# 10   device_pos
		# "10" device_relative_distance
			x_,y_ = xy
			args.split(2, []) do |(x,y),i,memo|
				x = String===x ? tdu(x.to_f)+x_     : du(x)
				y = String===y ? tdu(nil,y.to_f)+y_ : du(nil,y)
				memo.push(x,y)
			end
		end

		def __pos(*args) 
		# 7   user_pos
		# "7" user_relative_distance
		# :d7 device_pos
		# :r7 device_relative_distance
			x_,y_ = xy
			args.split(2, []) do |(x,y),i,memo|
				x = case x
				when /^d/
					du(x[1..-1].to_f)
				when /^r/
					tdu(x[1..-1].to_f) + x_
				when String
					x.to_f + x_
				else
					x
				end

				#p x,y,y_
				y = case y
				when /^d/
					du(nil, y[1..-1].to_f)
				when /^r/
					tdu(nil, y[1..-1].to_f) + y_
				when String
					y.to_f + y_
				else
					y
				end

				memo.push(x,y)
			end
		end # def __pos
				
		def __angle(*args) 
			rst = args.split(2, []) do |(a1,a2),i,memo|
				a1 = a1.to_f*Math::PI/180.0 unless String === a1
				a2 = a2.to_f*Math::PI/180.0 unless String === a2
				memo.push(a1,a2)
			end

			rst.gach!(&:to_f)
			args.size==1 ? rst[0] : rst
		end

		def __du(x,y)
		# 7 
		# "7"  device_to_user
			x = device_to_user(x.to_f,1)[0] if String === x
			y = device_to_user(1,y.to_f)[1] if String === y
			[x,y]
		end

		def __tdu(tx,ty)
		# 7
		# "7" device_to_user_distance
			tx = device_to_user_distance(tx.to_f,1)[0] if String === tx
			ty = device_to_user_distance(1,ty.to_f)[1] if String === ty
			[tx,ty]
		end

	public
		alias initialize_ initialize
		def initialize(surface) 
			initialize_(surface)
			move_to(0,0)

			self.dsize = 13
			self.dborder = 1

			@line_cap =line_cap_
			@line_join =line_join_
			@line_dash =line_dash_
			@font_matrix =font_matrix_
			@font_options =font_options_
			@font_face =font_face_
			@operator =operator_
			@antialias =antialias_
		end # def initialize

		attr_reader :size, :dsize, :border, :line_cap, :line_join, :line_dash, 
								:font_matrix, :font_options, :font_face, :operator, :antialias

		alias showglyphs show_glyphs
		alias line_cap_ line_cap
		alias line_join_ line_join
		alias line_dash_ dash
		alias font_matrix_ font_matrix
		alias font_options_ font_options
		alias font_face_ font_face
		alias operator_ operator
		alias antialias_ antialias
		alias showpage show_page
		alias copypage copy_page
		alias surface target

		alias textpath text_path
		alias glyphpath glyph_path

		def font_face family, slant=:normal, weight=:normal
			slant = Cairo.const_get("font_slant_#{slant}".upcase)
			weight = Cairo.const_get("font_weight_#{weight}".upcase)
			select_font_face family, slant, weight
		end

		alias size_= font_size=
		def size=(size)
			if String === size
				self.dsize = size.to_f
			else
				@dsize = ud(size)
				@size = size
				self.font_size = @size
			end
		end
		def dsize=(size)
			@dsize = size
			@size = tdu(size)
			self.font_size = @size
		end

		def font_matrix=(matrix)
			@font_matrix=matrix
			set_font_matrix(@font_matrix)
			@font_matrix
		end

		def font_options=(options)
			set_font_options( @font_options=options )
			@font_options
		end

		def font_face=(face)
			set_font_face( @font_face=face )
			@font_face
		end
						
		def text_scale_min
			min = tud(1,1).min
			bak(:scale) do
				dscale min, min
				yield
			end
		end

		def showtext(text, newline=false)
			text_scale_min do
				ascent, descent = font_extents.to_a
				mvxy('0', ascent.to_s)
				show_text(text.to_s)
				mvxy('0', (-ascent).to_s)
				mvxy(0, (ascent+descent).to_s) if newline
			end
		end

		def newline_height
			out = nil; prev=nil
			text_scale_min do
				ascent, descent = font_extents.to_a
				out = ascent+descent
				prev = tud(nil, 1)
			end

			cur = tud(nil, 1)
			out = prev/cur*out
			out
		end

		def newline
			mvxy(0, newline_height.to_s)
		end

		def sep(width, border="1")
			mvxy(0, "0")
			line("0","0", width, "0")
			bak(:border) do
				self.border = border
				stroke
			end
		end

		def centertext(text)
			advanced_x = nil
			advanced_x = text_extents(text.to_s).to_a[-2]
			mvxy( ((1-advanced_x)/2.0).to_s , '0')
			showtext(text, true)
		end

		def instroke?(x,y); in_stroke?(x,y) end
		def infill?(x,y); in_fill?(x,y) end

		alias set_source_ set_source
		def set_source(source)
			# [r,g,b,a=1.0] Pattern Surface
			# "#rgb[a]", "name"  (set_source_color)
			# Pixbuf             (set_source_pixbuf)
			case 
			when String===source
				set_source_color(source)
			when Array===source, source.kind_of?(Pattern), source.kind_of?(Surface)
				set_source_(source)
			else
				set_source_pixbuf(*args)
			end
		end

		def operator=(operator)
			@operator = Cairo.const_get("operator_#{operator}".upcase)
			set_operator(@operator)
			@operator
		end

		def antialias=(antialias)
			@antialias = Cairo.const_get("antianias_#{antialias}".upcase)
			set_antialias(@antialias)
			@antialias
		end

		alias fill_ fill
		def fill(keep=true)
			if keep
				xy = current_point
				fill_()
				move_to(*xy)
			else
				fill_()
			end
		end

		def mask(*args)
			if args[0].class == Pattern
				mask(args[0])
			elsif args[0].class == Surface
				mask_surface(*args)
			end
		end

		alias push_group_ push_group
		def push_group(context=false)
			if context
				push_group_widht_context(context)
			else
				push_group_
			end
		end

		alias pop_group_ pop_group
		def pop_group(to_source=false)
			group = pop_group_
			set_source(group) if to_source
			group
		end

		#alias xy_ move_to
		#def xy_(*xy) 	xy.empty? ? current_point : move_to(*xy) end
		def mvxy(*xy) 	xy.empty? ? current_point : move_to(*__pos(*xy)) end
		def dmvxy(*xy)	xy.empty? ? ud(*current_point) : move_to(*__dpos(*xy)) end
		def rmvxy(x,y) 		move_to(*__rpos(x,y)) end
		def rdmvxy(x,y)		move_to(*__tpos(x,y))	end

		#def dpos; ud(*pos) end

		def mvx(x=nil);  x ? mvxy(x, "0") : current_point[0] end
		def dmvx(x=nil); x ? dmvxy(x, "0") : ud(*current_point)[0] end
		def rmvx x;		rmvxy(x, 0) end
		def rdmvx x;	rdmvxy(x, 0) end

		def mvy(y=nil)  y ? mvxy("0", y ) : current_point[1] end
		def dmvy(y=nil) y ? dmvxy("0", y) : ud(*current_point)[1] end
		def rmvy y;		rmvxy(0, y) end
		def rmvdy y;	rdmvxy(0, y) end
		
		alias lineto_ line_to
		def lineto(x,y)  	line_to(*__pos(x,y) ) end
		def rlineto(x,y) 	line_to(*__rpos(x,y)) end
		def lineno(x,y) 	bak(:xy){lineto(x,y)} end
		def rlineno(x,y) 	bak(:xy){rlineto(x,y)} end
		def line(x,y, x1,y1)  bak(:xy){mvxy(x,y); lineto(x1,y1) } end
		def rline(x,y, x1,y1) bak(:xy){rmvxy(x,y); rlineto(x1,y1)} end

		def circle(x,y,r); arc(x,y,r,0,360) end
		alias arc_ arc
		def arc(x,y,r, a1,a2)
			x,y=__pos(x,y)
			a1,a2=__angle(a1,a2)
			new_path # need new_path to clear prior-path
			arc_(x,y,r,a1,a2)
		end

		alias arc_neg_ arc_negative
		def arg_neg(x,y,r, a1,a2)
			x,y=__pos(x,y)
			a1,a2=__angle(a1,a2)
			new_path
			arc_negative(x,y,r, a1,a2)
		end


		alias curveto_ curve_to
		def curveto(x1,y1, x2,y2, x3,y3)
			x1,y1,x2,y2,x3,y3=__pos(x1,y1,x2,y2,x3,y3)
			curve_to(x1,y1, x2,y2, x3,y3)
		end
		alias rcurveto_ rel_curve_to
		alias rcurveto rel_curve_to

		alias	new_subpath new_sub_path
		alias copy_path_ copy_path
		def copy_path(flat=false) flat ? copy_path_flat : copy_path_ end

		alias stroke_ stroke
		def stroke(preverse=false, &blk)
			bak(:xy) {
				stroke_(preverse, &blk)
			}
		end

		# border line_cap _join _dash 
		alias border_=  line_width=
		def border=(border)
			if String === border
				self.dborder = border.to_f
			else
				@dborder = ud(border)
				@border = border
				self.line_width = @border
			end
		end

		def dborder=(border)
			@dborder = border
			@border = tdu(border)
			self.line_width = @border
		end

		def line_cap=(cap)
			@line_cap = Cairo.const_get("line_cap_#{cap}".upcase)
			set_line_cap(@line_cap)
			@line_cap
		end

		def line_join=(join)
			@line_join = Cairo.const_get("line_join_#{join}".upcase)
			set_line_join(@line_join)
			@line_join
		end

		def line_dash=(arg, offset=0)
			@line_dash ||=arg
			set_line_dash(arg, offset)
			@line_dash
		end

		def has_pos?; has_current_point? ? true : false end

		# push pos
		def push
			@xy_stack ||=[]
			@xy_stack.push(current_point)
		end
		def pop
			@xy_stack.pop
		end


		alias rotate_ rotate
		def rotate(angle); rotate_(__angle(angle)) end

		alias scale_ scale
		# args@ tx,ty,keep=true
		# keep size border
		def scale(*args)
			if args.empty?
				tdu 1,1
			else
				tx, ty, keep = args
				keep ||= true
				tx,ty = __tdu(tx,ty)
				scale_(tx,ty)
				if keep
					self.dsize=@dsize
					self.dborder=@dborder
				end
			end
		end
		def dscale tx=1,ty=1, keep=true; scale tx.to_s, ty.to_s, keep end

		alias translate_ translate
		def translate(*txy)
			if txy.empty?
				ud 0,0
			else
				txy_ = xy
				translate_(*__du(*txy))
				mvxy(*txy_)
			end
		end

		def btranslate tx=0,ty=0; translate tx.to_s, ty.to_s end

		# ud tud du tdu 
		alias ud_ user_to_device
		alias tud_ user_to_device_distance
		# user_to_device
		# (x,nil) (nil,y) (x,y)
		def ud(x,y=nil)
			if y==nil
				user_to_device(x,0)[0]
			elsif x==nil
				user_to_device(0,y)[1]
			else
				user_to_device(x,y)
			end
		end

		# user_to_device_sitance
		# (x,nil) (nil,y) (x,y)
		def tud(x,y=nil)
			if y==nil
				user_to_device_distance(x, 0)[0]
			elsif x==nil
				user_to_device_distance(0, y)[1]
			else
				user_to_device_distance(x,y)
			end
		end

		alias du_ device_to_user
		alias tdu_ device_to_user_distance
		# device to user
		# (x,nil) (nil,y) (x,y)
		def du(x,y=nil)
			if y==nil
				device_to_user(x,0)[0]
			elsif x==nil
				device_to_user(0,y)[1]
			else
				device_to_user(x,y)
			end
		end

		# device to user distance
		# (x,nil) (nil,y) (x,y)
		def tdu(x,y=nil)
			if y==nil
				device_to_user_distance(x, 0)[0]
			elsif x==nil
				device_to_user_distance(0, y)[1]
			else
				device_to_user_distance(x,y)
			end
		end

		# options: xy x y translate scale matrix
		# state size
		def bak(name, *args) 
			case name.to_sym
			# :xy x y
			when :xy
				x_, y_ = user_to_device(*current_point)
				yield
				move_to( *device_to_user(x_, y_))
			when :x
				x_, y_ = user_to_device(*current_point)
				yield
				x = device_to_user(x_, y_)[0]
				y = current_point[1]
				move_to(x,y)
			when :y
				x_, y_ = user_to_device(*current_point)
				yield
				x = current_point[0]
				y = device_to_user(x_, y_)[1]
				move_to(x,y)

			# :translate scale matrix
			when :translate
				xy_d = ud(0,0)
				yield
				a = xy_d.gach(&:to_s)
				translate(*a)
			when :scale
				txy_d = tud(1,1)
				yield
				scale(*txy_d.gach(&:to_s))
			when :matrix  # combine translate and scale
				xy_d = ud(0,0)
				txy_d = tud(1,1)
				yield
				scale(*txy_d.gach(&:to_s))
				translate(*xy_d.gach(&:to_s))

			# state
			when :state
				save
				yield
				restore

			# size
			when :size
				size_ = @dsize
				yield
				self.dsize = size_
			when :border
				border_ = @dborder
				yield
				self.dborder = border_

			# all: save xy size
			when :all 
				x_, y_ = user_to_device(*current_point)
				size_ = @dsize
				save
				yield
				restore
				move_to( *device_to_user(x_, y_))
				self.dsize = size_
			else
				raise ArgumentError, "bak(:#{name})"
			end
		end # def bak
		# selection=[x|y=nil, w|h=nil]
		def paint_img(img, selection=nil, rotate=0, scale=1)  
			# handle arg selection
			selection ||= []
			select_x,select_y,select_w,select_h = selection
			select_x ||= 0; select_y ||= 0
			select_w ||= img.w-select_x; select_h ||= img.h-select_y
			select_w,select_h=1,1 if select_w<=0 or select_h<=0

			select_w,select_h = select_w*scale.to_f, select_h*scale.to_f
			select_x,select_y = select_x*scale.to_f, select_y*scale.to_f

			bak(:state) do

				# rotate 
				translate(surface.w/2, surface.h/2)
				rotate(rotate)
				translate(-select_w/2, -select_h/2)

				# selection [x,y,w,h]
				rectangle(0,0,select_w,select_h)
				clip
				translate(-select_x,-select_y)

				# scale
				scale(scale, scale)
				
				# paint
				set_source(img)
				paint
			end
		end # def paint_img

		# base on scale(*wh)
		# datas: \[ \[..\], \]
		def table(datas, oph={}) 

			# width height
			# row_nrs col_nrs
			cols = oph[:pos]
			spacing = oph[:spacing] || [4,1]
			spacing = tdu(*spacing)

			# ==>datas row_nrs and col_nrs
			datas = [datas] if not Array===datas[0]
			row_nrs = datas.size
			col_nrs = datas[0].size

			# ==> cell_height 0.05 height
			cell_height = newline_height + spacing[1]*2
			height =  cell_height * datas.size

			## ==>cols [0, 0.5, 1.0]
			# cell_widths [text_extents..]
			if oph[:pos] == "<" || oph[:pos] == ">"
				cell_widths = [0]
				cell_widths += datas.transpose.gach do |cols|
					cols.gach{|v| text_extents(v.to_s).to_a[-2]}.max
				end
			end

			case oph[:pos]
			when "<"
				if oph[:border]
					pos = cell_widths[0]+spacing[0]*2
					cols = [0, pos, pos+cell_widths[1]+spacing[0] ]
				else
					pos = cell_widths[0]+spacing[0]
					cols = [0, pos, pos+cell_widths[1]+spacing[0] ]
				end
			when ">"
				if oph[:border]
					pos = 1-(cell_widths[0]+cell_widths[1]+spacing[0]*4)
					cols = [ pos, pos+cell_widths[0]+spacing[0]*2, 1 ]
				else
					pos = 1-(cell_widths[0]+cell_widths[1]+spacing[0]*3)
					cols = [ pos, pos+cell_widths[0]+spacing[0], 1 ]
				end
			else
				cols ||= (0..col_nrs).map{|v| v/col_nrs.to_f}
			end
			width = cols[-1]


			# draw border 
			if oph[:border]
				rectangle cols[0], "0", cols[-1], height

				# draw rows
				bak(:xy) {
					row_nrs.each do 
						ry cell_height; rlineno cols[-1], 0
					end
				}

				# draw cols
				bak(:xy) {
					cols.gach do |v|
						x v; rlineno 0, height
					end
				}

				stroke
			end

			# draw text
			datas.gach do |rows|
				bak(:xy) {
					rxy 0, spacing[1]
					rows.gach do |row, i|
						xy cols[i], "0"
						rx spacing[0]
						showtext row
					end
				}
				ry cell_height
			end

			[width, height]
		end # def table

		# rectangle with rounded support 
		alias rectangle_ rectangle
		def rectangle(x,y,w,h)  rectangle_(*__pos(x,y), *__du(w,h) ) end
		def rrectangle(x,y,w,h) rectangle_(*__rpos(x,y), *__du(w,h) ) end

	end # class Context

end # module Cairo

=begin

Ncurses
@stdscr @curscr @newscr
@windows_hash
.
move(y,x)  «stdscr»
wmove(win, y,x)


== extensions

class MEVENT; end

class SCREEN; end

module Panel
	class PANEL; end
end

module Form
	class FORM; end
	class FIELD; end
	class FIELDTYPE; end
end

module Menu
	class MENU; end
	class ITEM; end
end

=end

module Ncurses
	def self.new &blk 
		begin
			initscr
			cbreak
			nonl
			noecho

			stdscr.intrflush(false)
			stdscr.keypad(true)   

			blk.call stdscr if blk
		ensure
			self.end if blk
		end
		stdscr
	end
	def self.end
		echo
		nocbreak
		nl
		endwin
	end
end # module Ncurses

module Ncurses # Key
class Key 
	include Comparable
	@@keys = {} 
	keys = String.letters.to_a + String.digits.to_a + \
				%w(` ~ ! @ # $ % ^ & * ( ) - _ = + \ | [ ] { } : " ' ; < . > / ? ,)
	keys.each do |v|
		@@keys[v] = v.ascii
	end
	@@codes = @@keys.invert

	attr_reader :key, :code

	def initialize(arg)
	# arg: int or str		
		if arg.class == Fixnum
			@code = arg
			@key = @@codes[arg]
		elsif arg.class == String
			@key = arg
			@code = @@keys[arg]
		end
	end

	def keys; @@keys end
	def codes; @@codes end

	def <=>(arg)
		if arg.class == self.class
			code <=> arg.code
		elsif arg.class == Fixnum
			code <=> arg
		elsif arg.class == String
			code <=> @@keys[arg]
		end
	end

	def to_s; "#{@key}: #{@code}" end

end # class Key
end

module Ncurses # WINDOW
class WINDOW 
	def initialize
		@stdscr = Ncurses.stdscr
		@curscr = Ncurses.curscr
	end

	# xy mvxy wh .. 
	def xy
		y,x=[],[]
		Ncurses.getyx(self,y,x)
		[x[0], y[0]]
	end
	def x; xy[0] end
	def y; xy[1] end

	def save; @save_xy = xy end
	def restore; xy *@save_xy end
	
	def mvxy x,y, &blk
		x,y = convert_xy(x,y)
		x_, y_ = self.xy
		Ncurses.move(y,x) 
		if blk
		blk.call
		Ncurses.move(y_, x_)
		end
	end

	def mvx x, &blk; mvxy(x, self.y) end
	def mvy y, &blk; mvxy(self.x, y) end

	def rmvxy x,y, &blk; mvxy(x.to_s, y.to_s, &blk) end
	def rmvx x, &blk; mvx(x.to_s, &blk) end
	def rmvy y, &blk; mvy(y.to_s, &blk) end

	def wh
		y,x=[],[]
		Ncurses.getmaxyx(self,y,x)
		[x, y]
	end
	def w; wh[0] end
	def h; wh[1] end

	def beginxy
		y,x=[],[]
		Ncurses.getbegyx(self,y,x)
		[x,y]
	end
	def beginx; beginxy[0] end
	def beginy; beginxy[1] end

	def convert_xy x=nil,y=nil
		x = self.x+x.to_i if x and String===x
		y = self.y+y.to_i if y and String===y

		if x and y
			[x,y]
		elsif x
			x
		elsif y
			y
		end
	end

	# getc 
	# ctrl_a      "\C-a"
	# alt_a  			"\ea"
	# ctrl_alt_a 	"\e\C-a"
	# KEYS #{{{2
	keys = {}
	Ncurses.constants.grep(/^KEY_/).each do |const|
		value = Ncurses.get_const const
		key = const[/^KEY_(.*)/, 1]
		keys[value] = key.downcase.to_sym
	end
	keys += { 
		127	=> 	:backspace,
		[27, 127]	=> :alt_backspace,

		289	=> 	:ctrl_f1, # :f25
		290	=> 	:ctrl_f2,
		291	=> 	:ctrl_f3,
		292	=> 	:ctrl_f4,
		293	=> 	:ctrl_f5,
		294	=> 	:ctrl_f6,
		295	=> 	:ctrl_f7,
		296	=> 	:ctrl_f8,
		297	=> 	:ctrl_f9,
		298	=> 	:ctrl_f1, 
		299	=> 	:ctrl_f11,
		300	=> 	:ctrl_f12,

		313	=>	:alt_f1,
		314	=>	:alt_f2,
		315	=>	:alt_f3,
		316	=>	:alt_f4,
		317	=>	:alt_f5,
		318	=>	:alt_f6,
		319	=>	:alt_f7,
		320	=>	:alt_f8,
		321	=>	:alt_f9,
		322 => 	:alt_f10,
		323 => 	:alt_f11,
		324 => 	:alt_f12,
	}
	KEYS = keys

	def getc
		key = getch
		if key==27
		c = getch
		(value=KEYS[[27, c]]) ?  value : "\e"+c.chr
		elsif value=KEYS[key]
		value
		else
		# a "\C-a"
		key.chr
		end
	end

	def necho(*args); Ncurses.addstr(args.gach{|v|v.to_s}.join(" ")) end
	def echo *args; necho *args, "\n" end

end # class WINDOW
end

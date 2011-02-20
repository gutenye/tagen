require "tagen/cairo"

include Cairo

tmpdir = Gile.dirname(__FILE__)+"/tmp"
Gile.rmdir!(tmpdir)
Gile.mkdir(tmpdir)
Gile.chdir(tmpdir)
#}}}1
DEBUG[0] = true

		Test.skip do
skip :table
		end

class Test_Context < Test
		def test_du #{{{1
		# (x_str,nil) (nil,y_str) (x_str, y_str), (x,y)
cr = Context.new(ImageSurface.new(200,200))
cr.scale(2,4)
cr.translate(10,10)

assert_equal 1, cr.tdu(2)
assert_equal 1, cr.tdu(nil, 4)
assert_equal [1,1], cr.tdu(2,4)
assert_equal [0,0], cr.du(20, 40)
		end # test_du
#}}}1
		def test___pos  #< du #{{{1
cr = Context.new(ImageSurface.new(200,200))
cr.translate(2,4)
cr.scale(2,4)
__pos = cr.method(:__pos)

cr.xy 10,10
assert_equal [0, 10], __pos.call(0, 10)
assert_equal __pos.call(0, cr.du(nil,0)), __pos.call(0, :d0)

cr.xy 10,10
assert_equal [0, 20], __pos.call(0, "10")
assert_equal [0, 10+cr.tdu(nil,10)], __pos.call(0, :r10)
		end
#}}}1
		def test__angle #{{{1
cr = Context.new(ImageSurface.new(200,200))
__angle = cr.method(:__angle)

assert_equal 10      , __angle.call("10")
assert_equal [10, 10], __angle.call("10", "10")
assert_equal [10*Math::PI/180.0, 10], __angle.call(10, "10")
			end
	#}}}1
		def test_bak #{{{1
cr = Context.new(ImageSurface.new(200,200))
# xy
cr.xy 0,0
cr.bak(:xy) do
	cr.xy 10,10
end
assert_equal [0,0], cr.xy

# translate
cr.translate(3,3)
cr.bak(:translate) do
	cr.translate(10,10)
end
assert_equal [0,0], cr.du(3,3)
cr.btranslate

# scale
cr.scale(2,4)
cr.bak(:scale) do
	cr.scale(2,4)
end
assert_equal [1,1], cr.tdu(2, 4)
cr.dscale 1,1

# matrix
cr.scale(2,4)
cr.translate(10,10)
cr.bak(:matrix) do
	cr.scale(2,4)
	cr.translate(10,10)
end
assert_equal [0,0], cr.du(20,40)
assert_equal [1,1], cr.tdu(2,4)
cr.dscale 1,1
cr.btranslate

# size
cr.size=10
cr.bak(:size) do
	cr.size=12
end
assert_equal 10, cr.size

# all
cr.size=10
cr.xy 0,0
cr.translate(3,3)
cr.bak(:all) do
	cr.xy 10,10
	cr.translate(10,10)
	cr.size=12
end
assert_equal [0,0], cr.xy
assert_equal [0,0], cr.du(3,3)
assert_equal 10, cr.size
		end # def test_bak
#}}}1
		def test_table #{{{1
wh=[400,400]
img = Cairo::ImageSurface.new(*wh)
cr = Cairo::Context.new(img)
cr.scale(*wh)
cr.rectangle(0,0,1,1); cr.stroke
cr.font= "iYahei"
#============

datas = [
	["你好","tag"],
	["你好","tag"],
]

cr.dxy 20,20
cr.table(datas[0], border:1)
cr.dry 20
cr.table(datas, border:1)
#============
img.write("a.png")
`pic a.png` 
		end
#}}}1
end



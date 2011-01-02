#!/usr/bin/env ruby
#{{{1

rrequire "../contact"
grequire "test"

include Contact

@tmpPa = Gfile.dirname(__FILE__).pj("tmp")
Gfile.mkdir(@tmpPa)
Gfile.cd(@tmpPa)

def test_at_exit
	Gfile.rm(@tmpPa, true)
end
#}}}1
class Test_Lib < Test

		def init 
@lib = Lib.new

@src_items = [
	Item.new(
		name: 			"Emily John", 
		nickname:  	"Linux"			,
		birthday:		"1000.01.10",
		phone:			%w(5715111 home:911),
		im:					%w(JID:emily11111111111111111@gmail.com QQ:111111),
		email:			%w(emliy@gmail.com emliy1@gmail.com),
		address:		"99 xiao road, China 111000",
		groups:			%w(Guten Zust),
		notes:			%Q(Guten tag, Ich bin guten. and thanks you. this is my note. note note note note note note note note note note note note note),
	),
	Item.new(
		name:				"Michael",
		nickname:		"Ruby",
		im:					%w(JID:michael@gmail.com),
	),]
	

@lib.instance_variable_set(:@items, @src_items.dup)
@items = @lib.items
@trashes = @lib.trashes
		end

		def test_id #{{{1
init
# test (:insert, from, to)
@lib.id(:insert,1,0)
@src_items.insert(0, @src_items.delete_at(1))
assert_equal @src_items, @items

# test (:list, [id])
# "0(guten)  1(tag).."
# ==>[0,1]
rst = @lib.id(:list)
rst = rst.scan(/(\d+)\(/).map{|v,|v.to_i}
assert_equal @src_items.size.to_a, rst

rst = @lib.id(:list, "0,1")
rst = rst.scan(/(\d+)\(/).map{|v,|v.to_i}
assert_equal [0,1], rst
		end
#}}}1
		def test___parse_item_id  #{{{1
init
parse_id = @lib.method(:__parse_item_id)

assert_equal [0,1], parse_id.call([0,1,5])
assert_equal [0,1], parse_id.call("0,1-5,4")
assert_equal [0,1], parse_id.call("*,1")
assert_equal [1], parse_id.call("1--1,1")
		end
#}}}1
		def test_search #{{{1
init
assert_equal [], @lib.search(:im, "msn:")
assert_equal [0,1], @lib.search(:im, "jid:")
assert_equal [0], @lib.search(:im, "jid:", "qq:")
		end
#}}}1

		def test___parse_cmd  #< __parse_item_id search #{{{1
init
parse_cmd = @lib.method(:__parse_cmd)
assert_equal [0], parse_cmd.call("0")

assert_equal [0,1], parse_cmd.call([0,1])
assert_equal [], parse_cmd.call(12)

assert_equal [0], parse_cmd.call("s name john")
		end
#}}}1
		def test_add  #< search #{{{1
init
# test_add
item = Item.new(name:1)
@src_items << item
@lib.add(item)

assert_equal @src_items, @items
assert_raises(Esame_name){@lib.add(item)}
		end
#}}}1

		def test_remove #{{{1
init
@lib.add({name:1})
@lib.remove(-1)
@src_items.delete_at(2)

assert_equal @src_items, @items
assert_equal [Item.new(name:1, delete_date:Date.today)], @trashes
		end
#}}}1
		def test_trash  #< __prase_id  remove #{{{1
		# :empty, :del id, :restore id, :list id
init
# :list
@trashes.clear
@trashes<<Item.new(name:1)
assert_equal [0], @lib.trash(:list)
assert_equal [0], @lib.trash(:list, "0,1")

# :empty
@lib.trash(:empty)
assert_equal [], @trashes

# :del
@trashes<<Item.new(name:1)
@lib.trash(:del, "*")
assert_equal [], @trashes

# :restore
@trashes<<Item.new(name:1)
@lib.trash(:restore, 0)
@src_items << Item.new(name:1)
assert_equal @src_items, @items
assert_equal [], @trashes
		end
#}}}1

	# test Item
		def test__output #{{{1
init

test("Item#_output(0, :short)")
@items.geach {|item, i|
	echo item._output(i, :short)
}

echo
test("Item#_output(0)")
@items.geach {|item, i|
	echo item._output(i)
}
		end
#}}}1
end


=begin
a = {
	["a"] => nil,
	["b"] => {
		[1] => nil,
		[2] => {
			[3] => nil, 
		}, 
	}, 
}

def travel tree, parent
	tree.each do |k,v|
		...
		travel v,k if v
	end
end
travel(a, nil)

== Usage

t = HTree.new do
	a "asset", :ASSET do
		a "cash", :ASSET
	end

	a "income", :INCOME do
		a "parent", :INCOME
	end

	a "expense", :EXPENSE do
		a "food", :EXPENSE
		a "phone", :EXPENSE
	end
end

t.each "" do |parent, *args|
  ...
  parent+"  "     -- return new parent
end
=end

class HTree 
	attr_reader :tree

	def initialize &blk
		@tree = {}
		instance_eval &blk
	end

	# build {} 
	def a(*args, &blk)
		if blk
			t = self.class.new &blk
			@tree[args] = t.tree
		else
			@tree[args] = nil
		end
	end

	def each(parent, &blk)
		__each(@tree, parent, &blk) 
	end

	# i'm rescurive
	def __each(tree, parent, &blk)
		tree.each do |args,subtree|
			newparent = blk.call parent, *args
			__each(subtree, newparent, &blk) if subtree
		end
	end
end

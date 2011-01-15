module Tree
	Fatal = Class.new Exception
	Error = Class.new Exception
	ENoNode = Class.new Error

	class TreeNode

		def get name
      return name if self.class===name
			treetage = Array===name ? name : name.split(/ +/)

      treetage.gach self.root do |n,i,m|
        if m[n]
          m[n]
        else
          raise ENoNode, "'#{n}` node doesn't exists for root `#{root.name}'"
        end
      end
		end

		def name= name
			old = @name
			@name = name
			children_hash = parent.instance_variable.get :@children_hash
			children_hash.delete old
			children_hash[@name] = self
		end

		alias oldparentage parentage
		# default => nil for root
		# now => [] for root
		def parentage
			is_root? ? [] : oldparentage
		end

		def treetage
			([self.name] + self.parentage.gach{|v| v.name}).reverse[1..-1]
		end

		def treename
			self.treetage.join(" ")
		end
      
		def __compare other
			raise ArgumentError, "comparison '{self}` with '{other}` failed"
				.format(self.class, other) unless self.class === other

			a = self.treetage
			b = other.treetage

			if a.length==b.length
				return 0 if a==b
			elsif a.length < b.length
				return 1 if a==b[0...a.length]
			elsif a.length>b.length
				return -1 if a[0...b.length]==b
			end
		end

		def same?(other) __compare(other)==0 ? true : false end
		def ancestor_of?(other) __compare(other)==1 ? true : false end
		def descendant_of?(other) __compare(other)==-1 ? true : false end
		def ancestor_in?(other) [0, 1].include?(__compare(other)) ? true : false end
		def descendant_in?(other) [0,-1].include?(__compare(other)) ? true : false end
	end
end

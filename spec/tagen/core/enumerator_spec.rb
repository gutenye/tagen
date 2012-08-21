require "spec_helper"

describe Enumerator do
	describe "#with_iobject" do
		it "has memo" do
			ret = [1, 2].each.with_iobject([]) { |v, i, m|
				m << v + i
      }
			expect(ret).to eq([1, 3])
		end

		it "has offset and memo" do
			ret = [1, 2].each.with_iobject(1, []) { |v, i, m|
				m << v + i
      }
			expect(ret).to eq([2, 4])
		end
	end
end

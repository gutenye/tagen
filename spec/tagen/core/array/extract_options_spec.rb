require "spec_helper"

describe Array do
	describe "#extract_options" do
		it do
			args = [1, {a: 1}, {b: 2}]
			nums, o = args.extract_options 
			expect(nums).to eq([1, {a: 1}])
      expect(o).to eq({b: 2})
      expect(args).to eq([1, {a: 1}, {b: 2}])
		end
	end

	describe "#extract_options!" do
		it do
			args = [1, {a: 1}, {b: 2}]
			o = args.extract_options!
			expect(o).to eq({b: 2})
      expect(args).to eq([1, {a: 1}])
		end
	end
end

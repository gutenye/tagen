class MatchData
	# group-name regexp
	# @return [Hash] {:name => "mathed-data"}
	def to_hash
		Hash[names.map(&:to_sym).zip(captures)]
	end
end

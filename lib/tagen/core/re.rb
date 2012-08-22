class MatchData
  # Returns a hash of named group matches.
  #
	# @return [Hash] {:name => "mathed-data"}
	def to_hash
		Hash[names.map(&:to_sym).zip(captures)]
	end
end

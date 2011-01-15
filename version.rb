module VERSION
	MAJOR = 0
	MINOR = 0
	PATCH = 1
	PRE   = 'beta'

	STRING = [MAJOR, MINOR, PATCH].join(".") + PRE
end

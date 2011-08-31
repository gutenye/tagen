module Tagen 
	module VERSION
		MAJOR = 1
		MINOR = 0
		PATCH = 4
    PRE   = nil

		IS = [MAJOR, MINOR, PATCH, PRE].compact.join(".") 
	end
end

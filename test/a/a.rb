class Customer
 attr_accessor :name

 def initialize(name)
	 @name = name
	 @rentals = Array.new
 end

 def addRental(aRental)
	 @rentals.push(aRental)
 end

 def statement
	 totalAmount = 0.0
	 frequentRenterPoints = 0
	 rentals = @rentals.length
	 result = "\nRental Record for #{@name}\n"
	 thisAmount = 0.0
	 @rentals.each do |rental| 
		 # determine amounts for each line
		 case rental.aMovie.pricecode
			 when Movie::REGULAR
			 thisAmount += 2
			 if rental.daysRented > 2
				 thisAmount += (rental.daysRented - 2) * 1.5
			 end

			 when Movie::NEW_RELEASE
			 thisAmount += rental.daysRented * 3

			 when Movie::CHILDRENS
				 thisAmount += 1.5
			 if each.daysRented > 3
				 thisAmount += (rental.daysRented - 3) * 1.5
			 end

		 end

		 # add frequent renter points
		 frequentRenterPoints += 1
		 # add bonus for a two day new release rental
		 if ( rental.daysRented > 1) && 
			(Movie::NEW_RELEASE == rental.aMovie.pricecode)
		 frequentRenterPoints += 1
		 end

		 # show figures for this rental
		 result +="\t#{rental.aMovie.title}\t#{thisAmount}\n"
		 totalAmount += thisAmount
	 end
	 result += "Amount owed is #{totalAmount}\n"
	 result += "You earned #{frequentRenterPoints} frequent renter points"
 end
end


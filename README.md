# Tagen, a core and extra extension to Ruby library. [![Build Status](https://secure.travis-ci.org/GutenYe/tagen.png)](http://travis-ci.org/GutenYe/tagen)

|                |                                         |
|----------------|-----------------------------------------|
| Homepage:      | https://github.com/GutenYe/tagen        |
| Author:	       | Guten                                   |
| License:       | MIT LICENSE                             |
| Documentation: | http://rubydoc.info/gems/tagen/frames   |
| Issue Tracker: | https://github.com/GutenYe/tagen/issues |

extensions defined in "active_support" will not appear in here, so you can use it with "active_support". 

Ruby has an 'Open Class' feature, so we can extend any class by ourself.

This library provides some usefull Ruby core extension.  some comes from ActiveSupport. ActiveSupport is mainly target to Rails, but tagen is target to generic ruby development, and tagen is smaller. It is a colletion of most common core,extra extensions.

This library comes with a string format lib named {PyFormat}.

Usage
-----

	require "tagen/core/array/extract_options"

	# @overload foo(*args, options={})
	def foo(*args)
		args, options = args.extract_options
	end


use core extension

	require "tagen/core"

then we have Time.time method, for a list of core extensions, see {file:docs/CoreExtensions.md docs/CoreExtensions}.

use extra extension

	require "tagen/pathname" # it also require "pathname"

this will add #path method to Pathname, see API doc.

An Introduction to PyFormat
---------------------------

	require "tagen/core"
	"I like %{fruit} and %{sport}".format('apple', 'football') 
	"I like %{fruit} and %{sport}".format(fruit: 'apple', sport: 'football') 

	"it costs %{howmatch:.2f} dollars".format(1.123) #=> "it costs 1.12 dollars"
	
more see API doc


Documentation
-------------

* {file:docs/CoreExtensions.md CoreExtensions} A list of core extensions.
* {file:docs/ExtraExtensions.md ExtraExtensions} A list of extra extensions.
* {file:docs/Architecture.md Architecture} Source code architecture.

Install
----------

	gem install tagen

Contributing
-------------

* Feel free to join the project and make contributions (by submitting a pull request)
* Submit any bugs/features/ideas to github issue tracker
* Coding Style Guide: https://gist.github.com/1105334

Contributors
------------

* [contributors](https://github.com/GutenYe/tagen/contributors)

Requirements
------------

* ruby 1.9.3

Copyright
---------

(the MIT License)

Copyright (c) 2011 Guten

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

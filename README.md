# Tagen, a core and extra extension for Ruby [![Build Status](https://secure.travis-ci.org/GutenYe/tagen.png)](http://travis-ci.org/GutenYe/tagen)

|                |                                         |
|----------------|-----------------------------------------|
| Homepage:      | https://github.com/GutenYe/tagen        |
| Author:	       | Guten Ye                                |
| License:       | MIT LICENSE                             |
| Documentation: | https://github.com/GutenYe/tagen/wiki   |
| Issue Tracker: | https://github.com/GutenYe/tagen/issues |
| Versions:      | Ruby 1.9.3, Rubinius                    |

It based on "active_support", but it focus on generic ruby programming.

Usage
-----

Cherry-picking a Definition

	require "tagen/core/array/delete_values"

	a = [1,2,3]
	a.delete_values(1, 3)  -> [1, 3]
	a                      -> [2]

Load All Core Extensions

	require "tagen/core"

Install
----------

	gem install tagen

Development [![Dependency Status](https://gemnasium.com/GutenYe/tagen.png?branch=master)](https://gemnasium.com/GutenYe/tagen) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/GutenYe/tagen)
===========

Contributing
-------------

* Submit any bugs/features/ideas to github issue tracker.

Pull requests are very welcome! Please try to follow these simple rules if applicable:

* Please create a topic branch for every separate change you make.
* Make sure your patches are well tested. All specs run with `rake spec:portability` must pass.
* Coding Style Guide: https://gist.github.com/1105334

Contributors
------------

* [https://github.com/GutenYe/tagen/contributors](https://github.com/GutenYe/tagen/contributors)

Resources
---------

* [activesupport](https://github.com/rails/rails/tree/master/activesupport): Utility classes and Ruby extensions from Rails
* [hashie](https://github.com/intridea/hashie): is a simple collection of useful Hash extensions.
* [facets](https://github.com/rubyworks/facets): is the premiere collection of general purpose method extensions and standard additions for the Ruby programming language.

Copyright
---------

(the MIT License)

Copyright (c) 2011-2012 Guten

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

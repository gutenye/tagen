Tagen, a core and extra extension to Ruby library.
==========================================
Ruby has an 'Open Class' feature, so we can extend any class by ourself.

This library provides some usefull Ruby core extension.  some comes from ActiveSupport. ActiveSupport is mainly target to Rails, but tagen is target to generic ruby development, and tagen is smaller. It is a colletion of most common core,extra extensions.

not support ruby1.8, win32

This library comes with a path lib named {Pa} and a string format lib named {PyFormat}.

Usage
-----
use core extension

	require "tagen/core"

then we have String#blank? method, for a list of core extensions, see {file:docs/CoreExtensions.md docs/CoreExtensions}.

use extra extension

	require "pathname"
	require "tagen/pathname"

add #path method to Pathname, see API doc.

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
	* report bugs/featues to issue tracker.
	* fork it and pull a request.
	* improve documentation.
	* any ideas are welcome.

See Also
--------
**ActiveSupport** [ActiveSupport Core Extension Guide](http://edgeguides.rubyonrails.org/active_support_core_extensions.html)


Info & Links
------------
**Homepage**: [http://github.com/GutenLinux/tagen](http://github.com/GutenLinux/tagen)
**Author**: 	Guten
**API-Docs**: yard
**Bugs**: github

Contributors
-------------

Copyright
---------
Copyright &copy; 2011 by Guten. this library released under MIT-License, See {file:License} for futher details.

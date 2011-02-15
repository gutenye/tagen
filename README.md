Tagen, a core and extra extension to Ruby library.
==========================================
provide some usefull Ruby core extension.  some comes from ActiveSupport. ActiveSupport is mainly target to Rails, but tagen is target to generic ruby development, and tagen is smaller.

Usage
-----
use core extension

	require "tagen/core" 

then we have String#blank? method, for a list of core extensions, see {file:docs/CoreExtensions}.

use extra extension

	require "pathname"
	require "tagen/pathname"

add #path method to Pathname, see api doc.


Install
----------
	gem install tagen

Contributing
-------------
	* fork it and pull a request.
	* report buts/featues to issue tracker.
	* improve documentation. (English is my second language)  
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

Copyright
---------
Copyright &copy; 2010 by Guten. this library released under MIT-License, See {file:License} for futher details.

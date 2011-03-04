Core extensions
==============
some come from ActiveSupport. 

Usage
-----
	require "tagen/core" # include "time", "date"

From Tagen
----------
* {Object#deepdup}

* {Numeric#div2}

* {String}.hexdigits octdigits letters uppercase lowercase

* {Array}
	* `#extract_extend_options!  extract_options!`
	* \#append
	* `#delete(*values) delete_at` _support delete more than one values_

* {Hash#delete}

* {IO#fd}

* {Time.time}

* {Process.exists?}(pid)

* {Marshal}.load dump  _add Pa support_

* {Pa} _a path lib_

* {MatchData#to_hash}

From ActiveSupport
------------------
see [ActiveSupport Core Extensions Guide](http://edgeguides.rubyonrails.org/active_support_core_extensions.html)

* `Object #blank? present? presence try`

* `Module #mattr_x`

* `Class #cattr_x`

* `String #strip_heredoc at from to`

* `Numeric #bytes kilobytes megabytes gigabytes terabytes petabytes exabytes`

* `Enumerable #sum many? exclude?`

* `Array #from to second third fourth fifth`

* `Array.wrap`

* `Hash #deep_merge[!]`

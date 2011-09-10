Core extensions
==============

Usage
-----

	require "tagen/core"
	# or
	require "tagen/core/string"


From Tagen
----------
* {Object#deepdup}

* {Kernel} 
	* `#linux? win32?`
	* `sh`
	* `blk2method`

* {Numeric#div2}

* {String}.hexdigits octdigits letters uppercase lowercase

* {Array}
	* `#extract_extend_options!  extract_options!`
	* `#append`
	* `#delete(*values) delete_at` _support delete more than one values_

* {Hash#delete}

* {IO#fd}

* {Time.time}

* {Process.exists?}(pid)

* {MatchData#to_hash}

* {PyFormat} _a string format libraray_

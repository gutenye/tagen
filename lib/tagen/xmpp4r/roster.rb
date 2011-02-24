=begin
* **Install**: gem(xmpp4r)
added:
	#unsubscribe
=end

module Jabber
module Roster
class Helper
	class RosterItem

		# unsubscribe an item
		def unsubscribe
			pres = Presence.new.set_type(:unsubscribe).set_to(jid.strip)
			@stream.send(pres) 
		end
	end # class RosterItem
end # Helper
end # module Roster
end # module Jabber

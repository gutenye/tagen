require "uri"

class URI::Generic
  def to_hash
    component.each.with_object({}) {|k, m|
      m[k] = send(k)
    }
  end
end

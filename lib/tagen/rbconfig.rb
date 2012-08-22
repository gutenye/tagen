require "rbconfig"

module RbConfig
  def self.[](key)
    CONFIG[key]
  end
end

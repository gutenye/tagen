require "rbconfig"

module RbConfig
  # short-cut method to CONFIG#[]
  def self.[](key)
    CONFIG[key]
  end
end

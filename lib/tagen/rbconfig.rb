require "rbconfig"

module RbConfig
  class << self
    def method_missing(name, *args, &blk)
      name = name.to_s
      if CONFIG.key?(name)
        CONFIG[name]
      elsif CONFIG.key?(name.upcase)
        CONFIG[name.upcase]
      else
        super(name, *args, &blk)
      end
    end


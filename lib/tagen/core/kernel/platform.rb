require "rbconfig"

module Kernel
private
  def linux?
    RbConfig::CONFIG["host_os"] =~ /linux|cygwin/
  end

  def mac?
    RbConfig::CONFIG["host_os"] =~ /mac|darwin/
  end

  def bsd?
    RbConfig::CONFIG["host_os"] =~ /bsd/
  end

  def windows?
    RbConfig::CONFIG["host_os"] =~ /mswin|mingw/
  end

  def solaris?
    RbConfig::CONFIG["host_os"] =~ /solaris|sunos/
  end

  # TODO: who knows what symbian returns?
  def symbian?
    RbConfig::CONFIG["host_os"] =~ /symbian/
  end

  def posix?
    linux? or mac? or bsd? or solaris? or begin 
      fork do end
      true
    rescue NotImplementedError, NoMethodError
      false
    end
  end
end

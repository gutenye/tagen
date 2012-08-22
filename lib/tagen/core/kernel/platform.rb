require "rbconfig"

module Kernel
private
  # Return true when ruby is running in Linux Operation System.
  def linux?
    RbConfig::CONFIG["host_os"] =~ /linux|cygwin/
  end

  # Return true when ruby is running in Mac OS X.
  def mac?
    RbConfig::CONFIG["host_os"] =~ /mac|darwin/
  end

  # Return true when ruby is running in BSD Operation System.
  def bsd?
    RbConfig::CONFIG["host_os"] =~ /bsd/
  end

  # Return true when ruby is running in Windows Operation System.
  def windows?
    RbConfig::CONFIG["host_os"] =~ /mswin|mingw/
  end

  # Return true when ruby is running in Solaris Windows Operation System.
  def solaris?
    RbConfig::CONFIG["host_os"] =~ /solaris|sunos/
  end

  # Return true when ruby is running in symbian.
  #
  # TODO: who knows what symbian returns?
  def symbian?
    RbConfig::CONFIG["host_os"] =~ /symbian/
  end

  # Return true when ruby is running in Posix-compablity Operation System.
  def posix?
    linux? or mac? or bsd? or solaris? or begin 
      fork do end
      true
    rescue NotImplementedError, NoMethodError
      false
    end
  end
end

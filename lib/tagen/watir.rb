require "watir"

# Cookies
module Watir
  class Browser
    # TODO: support windows.
    #
    # firefox only.
    def keep_cookies!
      require "tagen/selenium-webdriver/webdriver/firefox"

      launcher = driver.instance_variable_get("@bridge").instance_variable_get("@launcher")
      launcher.keep_cookies!
    end

    # Read cookies from Mozilla cookies.txt-style IO stream
    #
    # @param file [IO,String]
    #
    def load_cookies(file)
      now = ::Time.now

      io = case file
      when String
        open(file)
      else
        file
      end

      io.each_line do |line|
        line.chomp!
        line.gsub!(/#.+/, '')
        fields = line.split("\t")

        next if fields.length != 7

        name, value, domain, for_domain, path, secure, version = fields[5], fields[6], 
          fields[0], (fields[1] == "TRUE"), fields[2], (fields[3] == "TRUE"), 0

        expires_seconds = fields[4].to_i
        expires = (expires_seconds == 0) ? nil : ::Time.at(expires_seconds)
        next if expires and (expires < now)

        cookies.add(name, value, domain: domain, path: path, expires: expires, secure: secure)
      end

      io.close if String === file

      self
    end

    # Write cookies to Mozilla cookies.txt-style IO stream
    #
    # @param file [IO,String]
    def dump_cookies(file)
      io = case file
      when String
        open(file, "w")
      else
        file
      end

      cookies.to_a.each do |cookie|
        io.puts([
          cookie[:domain],
          "FALSE", # for_domain
          cookie[:path],
          cookie[:secure] ? "TRUE" : "FALSE",
          cookie[:expires].to_i.to_s,
          cookie[:name],
          cookie[:value]
        ].join("\t"))
      end

      io.close if String === file

      self
    end
  end
end

module Watir
  class Element
    # quick set value.
    #
    # @example
    #
    #  form = browser.form(id: "foo")
    #  form.set2("//input[@name='value']", "hello")
    #  form.set2("//input[@name='check']", true)
    #  form.set2("//select[@name='foo']", "Bar")
    #  form.set2("//textarea[@name='foo']", "bar")
    #
    def set2(selector, value=nil)
      elem = element(xpath: selector).to_subtype

      case elem
      when Watir::Radio
        elem.set
      when Watir::Select
        elem.select value
      when Watir::Input
        elem.set value
      when Watir::TextArea
        elem.set value
      else
        elem.click
      end
    end
  end
end

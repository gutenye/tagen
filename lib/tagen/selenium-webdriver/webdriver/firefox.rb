# keep_cookies!
module Selenium
  module WebDriver
    module Firefox
      class Launcher
        def keep_cookies!
          origin_profile_dir = @profile.instance_variable_get("@model")

          File.delete "#{@profile_dir}/cookies.sqlite"
          File.symlink "#{origin_profile_dir}/cookies.sqlite", "#{@profile_dir}/cookies.sqlite"
        end
      end
    end
  end
end

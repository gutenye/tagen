require "RMagick"

module Magick
  class Image
    # get columns, rows
    #
    # @return [Array] [width, height]
    def cr 
      [columns, rows] 
    end
  end
end

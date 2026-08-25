require "stumpy_png"

require "./util"
require "./entity"

module Raysetta
  class Image < Entity
    getter image : StumpyPNG::Canvas

    def initialize(path = nil, data_url : String? = nil)
      @image = if path
        StumpyPNG.read(path)
      elsif data_url
        match = /data:([\w\/\+]+);(charset=[\w-]+|base64).*,([a-zA-Z0-9+\/]+={0,2})/.match(data_url)
        raise ArgumentError.new("invalid data url") unless match
        StumpyPNG.read(IO::Memory.new(Base64.decode(match[3])))
      else
        raise ArgumentError.new("missing path or data_url")
      end
    end

    def width
      image.width
    end

    def height
      image.height
    end

    def [](x, y)
      r, g, b = image[x.clamp(0, width-1), y.clamp(0, height-1)].to_rgb8
      Vec3.new(r/255.0, g/255.0, b/255.0).tap do |col|
        col.r = Util.gamma_to_linear(col.r)
        col.g = Util.gamma_to_linear(col.g)
        col.b = Util.gamma_to_linear(col.b)
      end
    end

    def ==(other)
      image == other.image
    end

    def hash
      [type, image].hash
    end

    def export
      super.merge({
        :data => image.to_data_url
      })
    end
  end
end

require "stumpy_png"

require "./base"

module Raysetta
  module Output
    class PNG < Base
      def call
        image = StumpyPNG::Canvas.new(width, height)

        pixels.each.with_index do |row, y|
          row.each.with_index do |pixel, x|
            image[x, y] = StumpyPNG::RGBA.new(pixel.r, pixel.g, pixel.b)
          end
        end

        image
      end

      def save(file)
        image = call
        StumpyPNG.write(image, file)
      end
    end
  end
end

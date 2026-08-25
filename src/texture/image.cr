require "./base"
require "../image"

module Raysetta
  class Texture
    class Image < Texture
      property image : Raysetta::Image

      def initialize(@image)
      end

      def sample(uv, point)
        # Clamp input texture coordinates to [0,1] x [1,0]
        u = uv.u.clamp(0.0, 1.0)
        v = 1.0 - uv.v.clamp(0.0, 1.0)

        x = u*image.width + 0.5
        y = v*image.height + 0.5

        x1 = x.floor
        y1 = y.floor

        x2 = x.ceil
        y2 = y.ceil

        x2 = x1+1 if x2 == x1
        y2 = y1+1 if y2 == y1

        q11 = image[x1.to_i, y1.to_i]
        q12 = image[x1.to_i, y2.to_i]
        q21 = image[x2.to_i, y1.to_i]
        q22 = image[x2.to_i, y2.to_i]

        (q11*(x2-x)*(y2-y)+q21*(x-x1)*(y2-y)+q12*(x2-x)*(y-y1)+q22*(x-x1)*(y-y1)) / ((x2-x1)*(y2-y1)).to_f
      end

      def ==(other)
        image == other.image
      end

      def hash
        [type, image].hash
      end

      def export
        super.merge({
          :image => image.id
        })
      end

      def images
        [image]
      end
    end
  end
end

require "./base"

module Raysetta
  class Texture
    class Checker < Texture
      property inv_scale : Float64
      property even : Texture
      property odd : Texture

      def initialize(scale, @even, @odd)
        @inv_scale = 1.0 / scale
      end

      def self.solid(scale, even, odd)
        new(scale, SolidColor.new(even), SolidColor.new(odd))
      end

      def scale=(scale)
        @inv_scale = 1.0 / scale
      end

      def scale
        1.0 / @inv_scale
      end

      def sample(uv, point)
        x = (inv_scale * point.x).floor.to_i
        y = (inv_scale * point.y).floor.to_i
        z = (inv_scale * point.z).floor.to_i

        (x + y + z).even? ? even.sample(uv, point) : odd.sample(uv, point)
      end

      def ==(other)
        inv_scale == other.inv_scale &&
        even == other.even &&
        odd == other.odd
      end

      def hash
        [inv_scale, even, odd].hash
      end

      def export
        super.merge({
          :scale => scale,
          :even => even.export,
          :odd => odd.export
        })
      end
    end
  end
end

require "./base"
require "../vec3"

module Raysetta
  class Background
    class Gradient < Background
      property top : Vec3
      property bottom : Vec3

      def initialize(@top, @bottom)
      end

      def sample(r)
        unit_direction = r.direction.unit
        a = 0.5 * (unit_direction.y + 1.0)
        bottom * (1.0 - a) + top * a
      end

      def export
        super.merge({
          :top => top.to_a,
          :bottom => bottom.to_a
        })
      end
    end
  end
end

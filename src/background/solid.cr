require "./base"
require "../vec3"

module Raysetta
  class Background
    class Solid < Background
      property albedo : Vec3

      def initialize(@albedo)
      end

      def sample(r)
        albedo
      end

      def export
        super.merge({
          :albedo => albedo.to_a
        })
      end
    end
  end
end

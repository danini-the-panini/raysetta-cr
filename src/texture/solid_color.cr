require "./base"
require "../vec3"

module Raysetta
  class Texture
    class SolidColor < Texture
      property albedo : Vec3

      def initialize(@albedo)
      end

      def self.rgb(r, g, b)
        new(Vec3.new(r, g, b))
      end

      def sample(uv, point)
        albedo
      end

      def ==(other)
        albedo == other.albedo
      end

      def hash
        [type, albedo].hash
      end

      def export
        super.merge({
          :albedo => albedo.to_a
        })
      end
    end
  end
end

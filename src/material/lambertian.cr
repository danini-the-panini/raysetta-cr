require "./base"
require "../texture/base"

module Raysetta
  class Material
    class Lambertian < Material
      property texture : Texture

      def initialize(@texture)
      end

      def self.solid(albedo)
        new(Texture::SolidColor.new(albedo))
      end

      def scatter(r_in, rec)
        scatter_direction = rec.normal + Vec3.random_unit

        # Catch degenerate scatter direction
        scatter_direction = rec.normal if scatter_direction.zero?

        scattered = Ray.new(rec.point, scatter_direction, r_in.time)
        Scatter.new(scattered, texture.sample(rec.uv, rec.point))
      end

      def ==(other)
        return false unless other.is_a?(Lambertian)

        texture == other.texture
      end

      def hash
        [type, texture].hash
      end

      def export
        super.merge({ :texture => texture.id })
      end

      def textures
        [texture]
      end
    end
  end
end

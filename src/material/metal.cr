require "./base"
require "../texture/base"

module Raysetta
  class Material
    class Metal < Material
      property texture : Texture
      property fuzz : Float64

      def initialize(@texture, @fuzz)
      end

      def self.solid(albedo, fuzz)
        new(Texture::SolidColor.new(albedo), fuzz)
      end

      def scatter(r_in, rec)
        reflected = r_in.direction.reflect(rec.normal)
        reflected = reflected.normalize.add(Vec3.random_unit.mul(fuzz))
        scattered = Ray.new(rec.point, reflected, r_in.time)
        return if scattered.direction.dot(rec.normal) <= 0.0

        Scatter.new(scattered, texture.sample(rec.uv, rec.point))
      end

      def ==(other)
        return false unless other.is_a?(Metal)

        texture == other.texture && fuzz == other.fuzz
      end

      def hash
        [type, texture, fuzz].hash
      end

      def export
        super.merge({
          :texture => texture.id,
          :fuzz => fuzz,
        })
      end

      def textures
        [texture]
      end
    end
  end
end

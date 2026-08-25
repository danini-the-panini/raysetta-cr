require "./base"
require "../texture/base"

module Raysetta
  class Material
    class DiffuseLight < Material
      property texture : Texture

      def initialize(@texture)
      end

      def self.solid(albedo)
        new(Texture::SolidColor.new(albedo))
      end

      def emitted(uv, point)
        texture.sample(uv, point)
      end

      def ==(other)
        return false unless other.is_a?(DiffuseLight)

        texture == other.texture
      end

      def hash
        [type, texture].hash
      end

      def export
        super.merge({
          :texture => texture.id,
        })
      end

      def textures
        [texture]
      end
    end
  end
end

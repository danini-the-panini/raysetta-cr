require "./base"
require "../texture/base"

module Raysetta
  class Background
    class SphereMap < Background
      property texture : Texture

      def initialize(@texture)
      end

      def sample(r)
        unit_direction = r.direction.unit
        uv = Util.sphere_uv(unit_direction)
        texture.sample(uv, unit_direction)
      end

      def textures
        [texture]
      end

      def export
        super.merge({
          :texture => texture.id
        })
      end
    end
  end
end

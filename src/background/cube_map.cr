require "./base"
require "../texture/base"

module Raysetta
  class Background
    class CubeMap < Background
      property textures : Array(Texture)

      def initialize(@textures)
      end

      def sample(r)
        v = r.direction
        v_abs = v.abs
        if v_abs.z >= v_abs.x && v_abs.z >= v_abs.y
          # front/back
          face_index = v.z < 0.0 ? 5 : 4
          ma = 0.5 / v_abs.z
          uv = Vec2.new(v.z < 0.0 ? -v.x : v.x, v.y)
        elsif v_abs.y >= v_abs.x
          # top/bottom
          face_index = v.y < 0.0 ? 3 : 2
          ma = 0.5 / v_abs.y
          uv = Vec2.new(v.x, v.y < 0.0 ? v.z : -v.z)
        else
          # left/right
          face_index = v.x < 0.0 ? 1 : 0
          ma = 0.5 / v_abs.x
          uv = Vec2.new(v.x < 0.0 ? v.z : -v.z, v.y)
        end

        uv = uv * ma + Vec2.new(0.5, 0.5)
        textures[face_index].sample(uv, v.unit)
      end

      def export
        super.merge({
          :textures => textures.map(&.id)
        })
      end
    end
  end
end

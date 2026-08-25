require "../entity"

module Raysetta
  class Material < Entity
    def emitted(uv, point)
      Vec3.new
    end

    def scatter(r_in, rec)
      nil
    end

    def textures
      [] of Texture
    end
  end
end

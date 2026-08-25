require "../entity"

module Raysetta
  abstract class Texture < Entity
    abstract def sample(uv, point)

    def images
      [] of Image
    end

    def noises
      [] of Perlin
    end
  end
end

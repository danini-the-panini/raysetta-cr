require "../entity"

module Raysetta
  abstract class Background < Entity
    abstract def sample(r)

    def textures
      [] of Texture
    end

    def images
      [] of Image
    end
  end
end

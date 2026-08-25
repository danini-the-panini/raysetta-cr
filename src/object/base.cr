require "../entity"
require "../ray"
require "../hit"

module Raysetta
  abstract class Object3D < Entity
    abstract def hit(r : Ray, ray_t : Range(Float64, Float64)) : Hit?
    abstract def bounding_box : AABB

    def materials
      [] of Material
    end

    def objects
      [self]
    end
  end
end

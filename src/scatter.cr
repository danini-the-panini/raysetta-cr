require "./vec3"
require "./ray"

module Raysetta
  struct Scatter
    property ray : Ray
    property attenuation : Vec3

    def initialize(@ray, @attenuation)
    end
  end
end

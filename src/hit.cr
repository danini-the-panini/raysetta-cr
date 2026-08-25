require "./vec2"
require "./vec3"
require "./material/base"

module Raysetta
  struct Hit
    property point : Vec3
    property normal : Vec3
    property t : Float64
    property material : Material
    property uv : Vec2

    setter front_face : Bool

    def initialize(
      @t,
      @normal,
      @material,
      r,
      @point,
      @uv = Vec2.new
    )
      @front_face = true

      set_face_normal(r) if r
    end

    def front_face?
      @front_face
    end

    # Sets the hit's normal vector.
    # NOTE: `@normal` is assumed to have unit length.
    private def set_face_normal(r)
      @front_face = r.direction.dot(@normal) < 0
      @normal = @front_face ? @normal : -@normal
    end
  end
end

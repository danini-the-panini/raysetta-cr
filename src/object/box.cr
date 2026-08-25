require "./group"
require "../vec3"

module Raysetta
  class Object3D
    class Box < Group
      private getter a : Vec3
      private getter b : Vec3
      private getter material : Material

      def initialize(a, b, material)
        @a = a
        @b = b
        @material = material

        # Returns the 3D box (six sides) that contains the two opposite vertices a & b.

        # Construct the two opposite vertices with the minimum and maximum coordinates.
        min = Vec3.new([a.x, b.x].min, [a.y, b.y].min, [a.z, b.z].min);
        max = Vec3.new([a.x, b.x].max, [a.y, b.y].max, [a.z, b.z].max);

        dx = Vec3.new(max.x - min.x, 0.0, 0.0)
        dy = Vec3.new(0.0, max.y - min.y, 0.0)
        dz = Vec3.new(0.0, 0.0, max.z - min.z)

        super([
          Quad.new(Vec3.new(min.x, min.y, max.z),  dx,  dy, material), # front
          Quad.new(Vec3.new(max.x, min.y, max.z), -dz,  dy, material), # right
          Quad.new(Vec3.new(max.x, min.y, min.z), -dx,  dy, material), # back
          Quad.new(Vec3.new(min.x, min.y, min.z),  dz,  dy, material), # left
          Quad.new(Vec3.new(min.x, max.y, max.z),  dx, -dz, material), # top
          Quad.new(Vec3.new(min.x, min.y, min.z),  dx,  dz, material)  # bottom
        ] of Object3D)
      end

      def export
        {
          :type => "Box",
          :a => @a.to_a,
          :b => @b.to_a,
          :material => @material.id
        }
      end

      def materials
        [@material]
      end

      def to_s(depth=0)
        indent = "  "*depth
        "#{indent}Box { a=#{@a}, b=#{@b} }"
      end
    end
  end
end

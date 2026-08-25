require "./base"
require "../vec3"
require "../aabb"
require "../hit"
require "../material/base"

module Raysetta
  class Object3D
    class Quad < Object3D
      property q : Vec3
      property u : Vec3
      property v : Vec3
      property material : Material

      getter bounding_box : AABB

      private getter normal : Vec3
      private getter d : Float64
      private getter w : Vec3

      def initialize(@q, @u, @v, @material)
        n = u.cross(v)
        @normal = n.unit
        @d = @normal.dot(q)
        @w = n / n.dot(n)

        @bounding_box = compute_bounding_box
      end

      def hit(r : Ray, ray_t : Range(Float64, Float64)) : Hit?
        denom = normal.dot(r.direction)

        # No hit if the ray is parallel to the plane.
        return if denom.abs < 1e-8

        # Return if the hit point parameter t is outside the ray interval.
        t = (d - normal.dot(r.origin)) / denom
        return unless ray_t.includes?(t)

        # Determine the hit point lies within the planar shape using its plane coordinates.
        intersection = r.at(t)
        planar_hitpt_vector = intersection - q
        alpha = w.dot(planar_hitpt_vector.cross(v))
        beta = w.dot(u.cross(planar_hitpt_vector))

        uv = interior?(alpha, beta)
        return unless uv

        # Ray hits the 2D shape
        Hit.new(point: intersection, t: t, normal: normal, material: material, r: r, uv: uv)
      end

      def export
        super.merge({
          :q =>q.to_a,
          :u =>u.to_a,
          :v =>v.to_a,
          :material => material.id
        })
      end

      def materials
        [material]
      end

      def to_s(depth=0)
        indent = "  "*depth
        "#{indent}Quad { q=#{q}, u=#{u}, v=#{v} }"
      end

      private property :normal, :d, :w

      private def interior?(a, b)
        unit_interval = Interval.new(0.0, 1.0)
        # Given the hit point in plane coordinates, return nil if it is outside the
        # primitive, otherwise return the UV coordinates.

        return unless unit_interval.include?(a) && unit_interval.include?(b)

        Vec2.new(a, b)
      end

      private def compute_bounding_box
        # Compute the bounding box of all four vertices.
        bbox_diagonal1 = AABB.from_points(q, q + u + v)
        bbox_diagonal2 = AABB.from_points(q + u, q + v)
        AABB.from_aabbs([bbox_diagonal1, bbox_diagonal2])
      end
    end
  end
end

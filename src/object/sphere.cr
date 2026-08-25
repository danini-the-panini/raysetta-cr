require "./base"
require "../vec3"
require "../aabb"
require "../material/base"

module Raysetta
  class Object3D
    class Sphere < Object3D
      property center : Vec3
      property radius : Float64
      property material : Material

      getter bounding_box : AABB

      def initialize(@center, @radius, @material)
        rvec = Vec3.new(radius, radius, radius)
        @bounding_box = AABB.from_points(center - rvec, center + rvec)
      end

      def hit(r : Ray, ray_t : Range(Float64, Float64)) : Hit?
        hit_center(r, ray_t)
      end

      protected def hit_center(r, ray_t, center = @center) : Hit?
        oc = center - r.origin
        a = r.direction.length_squared
        h = r.direction.dot(oc)
        c = oc.length_squared - radius**2

        discriminant = h**2 - a*c
        return if discriminant < 0

        sqrtd = Math.sqrt(discriminant)

        # Find the nearest root that lies in the acceptable range.
        root = (h - sqrtd) / a
        unless ray_t.includes?(root)
          root = (h + sqrtd) / a
          return unless ray_t.includes?(root)
        end

        point = r.at(root)
        normal = (point - center) / radius

        Hit.new(
          point: point,
          r: r,
          normal: normal,
          t: root,
          material: material,
          uv: Util.sphere_uv(normal)
        )
      end

      def export
        super.merge({
          :center => center.to_a,
          :radius => radius,
          :material => material.id
        })
      end

      def materials
        [material]
      end

      def to_s(depth=0)
        indent = "  "*depth
        "#{indent}Sphere { radius=#{radius}, center=#{center} }"
      end
    end
  end
end

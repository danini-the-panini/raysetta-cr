require "./base"
require "../aabb"

module Raysetta
  class Object3D
    class Group < Object3D
      getter objects : Array(Object3D)
      getter bounding_box : AABB

      def initialize(@objects)
        @bounding_box = compute_bounding_box
      end

      def objects=(objs)
        @objects = objs
        @bounding_box = compute_bounding_box
      end

      def add(obj)
        @objects << obj
        @bounding_box = AABB.from_aabbs([@bounding_box, obj.bounding_box])
      end

      def hit(r : Ray, ray_t : Range(Float64, Float64)) : Hit?
        hit = nil
        closest_so_far = ray_t.end

        @objects.each do |object|
          if tmp = object.hit(r, ray_t.begin..closest_so_far)
            hit = tmp
            closest_so_far = hit.t
          end
        end

        hit
      end

      def export
        super.merge({
          :objects => objects.map { [_1.id, _1.export] }.to_h
        })
      end

      def materials
        @objects.flat_map(&:materials).uniq!
      end

      def to_s(depth=0)
        indent = "  "*depth
        "#{indent}Group {\n" +
        "#{indent}  objects = {" +
        "#{@objects.map { _1.to_s(depth+2)+"\n" } }" +
        "#{indent}  }\n" +
        "#{indent}}"
      end

      private def compute_bounding_box
        AABB.from_aabbs(objects.map(&.bounding_box))
      end
    end
  end
end

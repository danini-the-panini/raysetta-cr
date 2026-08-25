require "./base"
require "./group"
require "../aabb"

module Raysetta
  class Object3D
    class BVH < Object3D
      getter bounding_box : AABB

      private getter left : Object3D
      private getter right : Object3D

      def initialize(objects : Array(Object3D))
        @bounding_box = AABB::EMPTY
        @left = @right = Group.new([] of Object3D)
        self.objects = objects
      end

      def hit(r : Ray, ray_t : Range(Float64, Float64)) : Hit?
        return unless bounding_box.hit(r, ray_t)

        hit_left = @left.hit(r, ray_t)
        t_max = if hit_left
          hit_left.t
        else
          ray_t.end
        end
        hit_right = @right.hit(r, ray_t.begin..t_max)

        hit_right || hit_left
      end

      def export
        export_bvh(@left).merge(export_bvh(@right))
      end

      def materials
        [*@left.materials, *@right.materials].uniq
      end

      def objects
        @left.objects | @right.objects
      end

      def objects=(objs : Array(Object3D))
        @bounding_box = AABB::EMPTY
        objs.each do |object|
          @bounding_box = AABB.from_aabbs([@bounding_box, object.bounding_box])
        end

        axis = @bounding_box.longest_axis

        case objs.size
        when 1
          @left = @right = objs[0]
        when 2
          @left = objs[0]
          @right = objs[1]
        else
          objs.sort_by!(&.bounding_box[axis].min)
          mid = objs.size // 2
          left_objs = objs[0...mid]
          right_objs = objs[mid..]
          @left = BVH.new(left_objs)
          @right = BVH.new(right_objs)
        end
      end

      def add(object)
        self.objects = objects + [object]
      end

      def to_s(depth=0)
        indent = "  "*depth
        "#{indent}BVH {\n" +
        "#{indent}  left=\n"+
        "#{@left.to_s(depth+2)}\n"+
        "#{indent}  right=\n"+
        "#{@right.to_s(depth+2)}\n"+
        "#{indent}}"
      end

      private def export_bvh(obj)
        case obj
        when BVH then obj.export
        else { obj.id => obj.export }
        end
      end
    end
  end
end

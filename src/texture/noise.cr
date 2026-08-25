require "./base"

module Raysetta
  class Texture
    class Noise < Texture
      property scale : Float64
      property depth : Int32
      property marble_axis : Symbol

      def initialize(@scale, @depth, @marble_axis, @noise=Perlin.new)
      end

      def sample(uv, point)
        if marble_axis
          Vec3.new(0.5) * (1.0 + Math.sin(scale * point[marble_axis] + 10.0 * @noise.turb(point, depth)))
        else
          Vec3.new(1.0) * @noise.turb(point, depth)
        end
      end

      def ==(other)
        scale == other.scale &&
        depth == other.depth &&
        marble_axis == other.marble_axis &&
        noise == other.noise
      end

      def hash
        [scale, depth, marble_axis, noise].hash
      end

      def export
        super.merge({:scale => scale, :depth => depth, :marble_axis => marble_axis.to_s, :noise => @noise.id })
      end

      def noises
        [@noise]
      end

      protected getter :noise
    end
  end
end

require "./vec3"

module Raysetta
  struct Ray
    property origin : Vec3
    property direction : Vec3
    property time : Float64

    def initialize(@origin, @direction, @time = 0.0)
    end

    def at(t)
      (direction*t).add(origin)
    end

    def dup
      self.class.new(origin.dup, direction.dup, time)
    end

    def ==(other)
      origin == other.origin &&
      direction == other.direction &&
      (time- other.time).abs < Util::EPSILON
    end

    def hash
      [origin, direction, time].hash
    end
  end
end

module Raysetta
  struct Interval
    property min : Float64
    property max : Float64

    # Default interval is empty
    def initialize(@min = Float64::INFINITY, @max = -Float64::INFINITY)
    end

    def self.from_range(r)
      new(r.begin, r.end)
    end

    # Create the interval tightly enclosing the two input intervals.
    def self.from_intervals(a, b)
      new(
        a.min <= b.min ? a.min : b.min,
        a.max >= b.max ? a.max : b.max
      )
    end

    def size
      max - min
    end

    def include?(x)
      min <= x && x <= max
    end

    def surround?(x)
      min < x && x < max
    end

    def clamp(x)
      return min if x < min
      return max if x > max
      x
    end

    def expand(delta)
      padding = delta / 2.0
      Interval.new(min - padding, max + padding)
    end

    def expand!(delta)
      padding = delta / 2.0
      self.min -= padding
      self.max += padding
      self
    end

    def dup
      Interval.new(min, max)
    end

    def ==(other)
      min == other.min && max == other.max
    end

    def hash
      [min, max].hash
    end

    EMPTY = new(Float64::INFINITY, -Float64::INFINITY)
    UNIVERSE = new(-Float64::INFINITY, Float64::INFINITY)
  end
end

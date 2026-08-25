require "./interval"

module Raysetta
  struct AABB
    property x : Interval
    property y : Interval
    property z : Interval

    # The default AABB is empty, since intervals are empty by default.
    def initialize(@x = Interval.new, @y = Interval.new, @z = Interval.new)
      pad_to_minimums
    end

    # Treat the two points a and b as extrema for the bounding box, so we don't require a
    # particular minimum/maximum coordinate order.
    def self.from_points(*points)
      x = points.minmax_of(&.x)
      y = points.minmax_of(&.y)
      z = points.minmax_of(&.z)
      new(Interval.new(x[0], x[1]), Interval.new(y[0], y[1]), Interval.new(z[0], z[1]))
    end

    def self.from_aabbs(aabbs : Array(AABB))
      return EMPTY if aabbs.empty?
      return aabbs.first if aabbs.size == 1

      aabbs.reduce do |a, b|
        a + b
      end
    end

    def [](n)
      case n
      when 0 then x
      when 1 then y
      else z
      end
    end

    def []=(n, v)
      case n
      when 0 then self.x = v
      when 1 then self.y = v
      when 2 then self.z = v
      end
    end

    def +(other)
      AABB.new(
        Interval.from_intervals(x, other.x),
        Interval.from_intervals(y, other.y),
        Interval.from_intervals(z, other.z)
      )
    end

    def hit(r, ray_t)
      t = Interval.from_range(ray_t)

      (0...3).each do |axis|
        ax = self[axis]
        adinv = 1.0 / r.direction[axis]

        t0 = (ax.min - r.origin[axis]) * adinv
        t1 = (ax.max - r.origin[axis]) * adinv

        if t0 < t1
          t.min = t0 if t0 > t.min
          t.max = t1 if t1 < t.max
        else
          t.min = t1 if t1 > t.min
          t.max = t0 if t0 < t.max
        end

        return false if t.max <= t.min
      end

      true
    end

    # Returns the index of the longest axis of the bounding box.
    def longest_axis
      if x.size > y.size
        x.size > z.size ? 0 : 2
      else
        y.size > z.size ? 1 : 2
      end
    end

    def dup
      AABB.new(x.dup, y.dup, z.dup)
    end

    def ==(other)
      x == other.x && y == other.y && z == other.z
    end

    def hash
      [x, y, z].hash
    end

    # Adjust the AABB so that no side is narrower than some delta, padding if necessary.
    private def pad_to_minimums
      delta = 0.0001
      x.expand!(delta) if x.size < delta
      y.expand!(delta) if y.size < delta
      z.expand!(delta) if z.size < delta
    end

    EMPTY = new(Interval::EMPTY, Interval::EMPTY, Interval::EMPTY)
    UNIVERSE = new(Interval::UNIVERSE, Interval::UNIVERSE, Interval::UNIVERSE)

  end
end

module Raysetta
  struct Pixel
    property r : UInt8
    property g : UInt8
    property b : UInt8

    def initialize(@r, @g, @b)
    end

    def set(r, g, b)
      @r = r
      @g = g
      @b = b
    end

    def copy(other)
      set(other.r, other.g, other.b)
    end

    def to_a
      [r, g, b]
    end
  end
end

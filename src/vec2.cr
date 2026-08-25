require "./util"

module Raysetta
  struct Vec2
    property :x, :y

    alias_property :u, :x
    alias_property :v, :y

    def initialize(x = 0.0, y = x)
      @x = x
      @y = y
    end

    def self.random(min = 0.0, max = 1.0)
      Vec2.new(Util.random(min, max), Util.random(min, max))
    end

    def self.sample_square
      new(rand - 0.5, rand - 0.5)
    end

    def to_a
      [x, y]
    end

    def [](i)
      return x if i == 0
      return y if i == 1
      0.0
    end

    def []=(i, v)
      self.x = v if i == 0
      self.y = v if i == 1
    end

    def -
      Vec2.new(-x, -y)
    end

    def +(v)
      Vec2.new(x + v.x, y + v.y)
    end

    def -(v)
      Vec2.new(x - v.x, y - v.y)
    end

    def *(t)
      Vec2.new(x * t, y * t)
    end

    def /(t)
      self * (1.0/t)
    end

    def add(v)
      self.x += v.x
      self.y += v.y
      self
    end

    def sub(v)
      self.x -= v.x
      self.y -= v.y
      self
    end

    def mul(t)
      self.x *= t
      self.y *= t
      self
    end

    def div(t)
      mul(1.0/t)
      self
    end

    def neg
      self.x = -x
      self.y = -y
      self
    end

    def length
      Math.sqrt(length_squared)
    end

    def length_squared
      dot(self)
    end

    def dot(v)
      x * v.x + y * v.y
    end

    def unit
      self / length
    end

    def normalize
      div(length)
      self
    end

    def dup
      Vec2.new(x, y)
    end

    def abs!
      self.x = x.abs
      self.y = y.abs
      self
    end

    def abs
      Vec2.new(x.abs, y.abs)
    end

    # Return true if the vector is close to zero in all dimensions.
    def zero?
      x.abs < Util::EPSILON &&
      y.abs < Util::EPSILON
    end

    def to_s
      "(#{x}, #{y})"
    end

    def ==(v)
      (x - v.x).abs < Util::EPSILON && (y - v.y).abs < Util::EPSILON
    end

    def eql?(v)
      x == v.x && y == v.y
    end

    def hash
      [x, y].hash
    end
  end
end

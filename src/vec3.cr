require "./util"
require "./pixel"

module Raysetta
  struct Vec3
    property x : Float64
    property y : Float64
    property z : Float64

    alias_property :r, :x
    alias_property :g, :y
    alias_property :b, :z

    def initialize(@x = 0.0)
      @y = x
      @z = x
    end

    def initialize(@x, @y, @z)
    end

    def self.random(min = 0.0, max = 1.0)
      Vec3.new(Util.random(min, max), Util.random(min, max), Util.random(min, max))
    end

    def self.random_in_unit_sphere
      loop do
        v = random(-1.0, 1.0)
        return v if v.length_squared < 1
      end
    end

    def self.random_unit
      random_in_unit_sphere.normalize
    end

    def self.random_on_hemisphere(normal)
      on_unit_sphere = random_unit
      if on_unit_sphere.dot(normal) > 0.0 # In the same hemisphere as the normal
        on_unit_sphere
      else
        -on_unit_sphere
      end
    end

    def self.random_in_unit_disk
      loop do
        v = new(Util.random(-1.0, 1.0), Util.random(-1.0, 1.0), 0.0)
        return v if v.length_squared < 1
      end
    end

    def to_a
      [x, y, z]
    end

    def [](i : Int)
      return x if i == 0
      return y if i == 1
      return z if i == 2
      0.0
    end

    def [](i : Symbol)
      case i
      when :r, :x then x
      when :g, :y then y
      when :b, :z then z
      else 0.0
      end
    end

    def []=(i, v)
      self.x = v if i == 0
      self.y = v if i == 1
      self.z = v if i == 2
    end

    def -
      Vec3.new(-x, -y, -z)
    end

    def +(other)
      Vec3.new(x + other.x, y + other.y, z + other.z)
    end

    def -(other)
      Vec3.new(x - other.x, y - other.y, z - other.z)
    end

    def *(other)
      Vec3.new(x * other, y * other, z * other)
    end

    def /(other)
      self * (1.0/other)
    end

    def add(other)
      self.x += other.x
      self.y += other.y
      self.z += other.z
      self
    end

    def sub(other)
      self.x -= other.x
      self.y -= other.y
      self.z -= other.z
      self
    end

    def mul(other)
      self.x *= other
      self.y *= other
      self.z *= other
      self
    end

    def multiply(other)
      self.x *= other.x
      self.y *= other.y
      self.z *= other.z
      self
    end

    def times(other)
      dup.multiply(other)
    end

    def div(other)
      mul(1.0/other)
      self
    end

    def neg
      self.x = -x
      self.y = -y
      self.z = -z
      self
    end

    def length
      Math.sqrt(length_squared)
    end

    def length_squared
      dot(self)
    end

    def dot(other)
      x * other.x + y * other.y + z * other.z
    end

    def unit
      self / length
    end

    def normalize
      div(length)
      self
    end

    def dup
      Vec3.new(x, y, z)
    end

    def abs!
      self.x = x.abs
      self.y = y.abs
      self.z = z.abs
      self
    end

    def abs
      Vec3.new(x.abs, y.abs, z.abs)
    end

    def floor
      Vec3.new(x.floor, y.floor, z.floor)
    end

    def smoothstep!
      self.x = x**2 * (3.0 - 2.0 * x)
      self.y = y**2 * (3.0 - 2.0 * y)
      self.z = z**2 * (3.0 - 2.0 * z)
      self
    end
    def smoothstep
      dup.smoothstep!
    end

    def cross(v)
      Vec3.new(
        y * v.z - z * v.y,
        z * v.x - x * v.z,
        x * v.y - y * v.x
      )
    end

    def reflect(n)
      self - n * (dot(n) * 2.0)
    end

    def refract(n, etai_over_etat)
      cos_theta = [(-self).dot(n), 1.0].min
      r_out_perp = (self + n * cos_theta).mul(etai_over_etat)
      r_out_parallel = n * -Math.sqrt((1.0 - r_out_perp.length_squared).abs)
      r_out_perp.add(r_out_parallel)
    end

    def to_pixel
      # Apply a linear to gamma transform for gamma 2
      rg = Util.linear_to_gamma(r)
      gg = Util.linear_to_gamma(g)
      bg = Util.linear_to_gamma(b)

      # Translate the [0,1] component values to the byte range [0,255].
      intensity = Interval.new(0.000, 0.999)
      rbyte = (256 * intensity.clamp(rg)).clamp(0, 255).to_u8
      gbyte = (256 * intensity.clamp(gg)).clamp(0, 255).to_u8
      bbyte = (256 * intensity.clamp(bg)).clamp(0, 255).to_u8

      # Return the pixel color components.
      Pixel.new(rbyte, gbyte, bbyte)
    end

    def zero?
      x.abs < Util::EPSILON &&
      y.abs < Util::EPSILON &&
      z.abs < Util::EPSILON
    end

    def to_s
      "(#{x}, #{y}, #{z})"
    end

    def ==(v)
      (x - v.x).abs < Util::EPSILON &&
      (y - v.y).abs < Util::EPSILON &&
      (z - v.z).abs < Util::EPSILON
    end

    def eql?(v)
      x == v.x && y == v.y && z == v.z
    end

    def hash
      [x, y, z].hash
    end
  end
end

require "./entity"
require "./vec3"

module Raysetta
  class Perlin < Entity
    POINT_COUNT = 256

    property randvec : Array(Vec3)
    property perm_x : Array(Int32)
    property perm_y : Array(Int32)
    property perm_z : Array(Int32)

    def initialize(
      @randvec = Array.new(POINT_COUNT) { Vec3.random(-1.0, 1.0).normalize },
      @perm_x = (0...POINT_COUNT).to_a.shuffle!,
      @perm_y = (0...POINT_COUNT).to_a.shuffle!,
      @perm_z = (0...POINT_COUNT).to_a.shuffle!
    )
    end

    def noise(point : Vec3)
      ivec = point.floor
      i = ivec.x.to_i32
      j = ivec.y.to_i32
      k = ivec.z.to_i32
      vec = point - ivec

      c = Array.new(2) { Array.new(2) { Array.new(2) { Vec3.new(0.0, 0.0, 0.0) } } }

      CUBE.each do |(d_i, d_j, d_k)|
        c[d_i][d_j][d_k] = @randvec[
          @perm_x[(i + d_i) & 255] ^
          @perm_y[(j + d_j) & 255] ^
          @perm_z[(k + d_k) & 255]
        ]
      end

      Perlin.perlin_interp(c, vec)
    end

    def turb(point, depth)
      accum = 0.0
      temp_p = point
      weight = 1.0

      (0...depth).each do
        accum += weight * noise(temp_p)
        weight *= 0.5
        temp_p *= 2.0
      end

      accum.abs
    end

    def ==(other)
      randvec == other.randvec &&
      perm_x == other.perm_x &&
      perm_y == other.perm_y &&
      perm_z == other.perm_z
    end

    def hash
      [randvec, perm_x, perm_y, perm_z].hash
    end

    def export
      super.merge({
        :randvec => randvec.map(&:to_a),
        :perm_x => perm_x,
        :perm_y => perm_y,
        :perm_z => perm_z,
      })
    end

    def self.perlin_interp(c, vec)
      v = vec.smoothstep
      CUBE.sum do |(i, j, k)|
        weight = vec - Vec3.new(i.to_f, j.to_f, k.to_f)
        (i * v.x + (1 - i) * (1 - v.x)) *
        (j * v.y + (1 - j) * (1 - v.y)) *
        (k * v.z + (1 - k) * (1 - v.z)) *
        c[i][j][k].dot(weight)
      end
    end

    CUBE = Indexable.cartesian_product([[0, 1], [0, 1], [0, 1]])
  end
end

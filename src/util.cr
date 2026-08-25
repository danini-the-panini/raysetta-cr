macro alias_method(new_method, old_method)
  def {{ new_method.id }}(*args)
    {{ old_method.id }}(*args)
  end
end

macro alias_property(new_prop, old_prop)
  def {{ new_prop.id }}
    {{ old_prop.id }}
  end
  def {{ new_prop.id }}=(v)
    {{ old_prop.id }} = v
  end
end

module Raysetta
  module Util
    EPSILON = 1e-8

    def self.degrees_to_radians(degrees)
      degrees * Math::PI / 180.0
    end

    # Returns a random real in [min,max).
    def self.random(min, max)
      min + (max-min)*rand
    end

    def self.linear_to_gamma(linear_component)
      return 0.0 unless linear_component > 0.0

      Math.sqrt(linear_component)
    end

    def self.gamma_to_linear(gamma_component, gamma = 2.2)
      return 0.0 unless gamma_component > 0.0

      gamma_component ** gamma
    end

    def self.sphere_uv(point)
      # point: a given point on the sphere of radius one, centered at the origin.
      # u:     returned value [0,1] of angle around the Y axis from X=-1.
      # v:     returned value [0,1] of angle from Y=-1 to Y=+1.
      #     <1 0 0> yields <0.50 0.50>       <-1  0  0> yields <0.00 0.50>
      #     <0 1 0> yields <0.50 1.00>       < 0 -1  0> yields <0.50 0.00>
      #     <0 0 1> yields <0.25 0.50>       < 0  0 -1> yields <0.75 0.50>

      theta = Math.acos(-point.y);
      phi = Math.atan2(-point.z, point.x) + Math::PI;

      Vec2.new(phi / (2.0*Math::PI), theta / Math::PI)
    end
  end
end

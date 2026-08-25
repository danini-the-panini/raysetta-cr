require "./base"
require "../scatter"

module Raysetta
  class Material
    class Dielectric < Material
      # Refractive index in vacuum or air, or the ratio of the material's refractive index over
      # the refractive index of the enclosing media
      property refraction_index : Float64

      def initialize(@refraction_index)
      end

      def scatter(r_in, rec)
        attenuation = Vec3.new(1.0)
        ri = rec.front_face? ? 1.0/refraction_index : refraction_index

        unit_direction = r_in.direction.unit
        cos_theta = [(-unit_direction).dot(rec.normal), 1.0].min
        sin_theta = Math.sqrt(1.0 - cos_theta**2)

        cannot_refract = ri * sin_theta > 1.0
        direction = if cannot_refract || reflectance(cos_theta, ri) > rand
          unit_direction.reflect(rec.normal)
        else
          unit_direction.refract(rec.normal, ri)
        end

        scattered = Ray.new(rec.point, direction, r_in.time)

        Scatter.new(scattered, attenuation)
      end

      def export
        super.merge({
          :refraction_index => refraction_index
        })
      end

      def ==(other)
        return false unless other.is_a?(Dielectric)

        refraction_index == other.refraction_index
      end

      def hash
        [type, refraction_index].hash
      end

      private def reflectance(cosine, ri)
        # Use Schlick's approximation for reflectance.
        r0 = ((1.0 - ri) / (1.0 + ri))**2
        r0 + (1.0-r0)*(1.0-cosine)**5
      end
    end
  end
end

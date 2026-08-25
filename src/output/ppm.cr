module Raysetta
  module Output
    class PPM < Base
      def call
        String.build do |buffer|
          buffer << "P3\n#{width} #{height}\n255\n"

          pixels.each do |row|
            row.each do |pixel|
              buffer << pixel.to_a.join(' ') << "\n"
            end
          end
        end
      end
    end
  end
end

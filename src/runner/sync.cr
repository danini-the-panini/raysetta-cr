require "./base"
require "../pixel"

module Raysetta
  module Runner
    class Sync < Base
      def call : Array(Array(Pixel))
        output = Array.new(tracer.height) do |y|
          Array.new(tracer.width) do |x|
            tracer.call(x, y)
          end.tap { step }
        end
        finish
        output
      end
    end
  end
end

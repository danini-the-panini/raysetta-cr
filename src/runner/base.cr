require "progress"

require "../pixel"
require "../tracer"

module Raysetta
  module Runner
    abstract class Base
      property tracer : Tracer

      private getter progress : ProgressBar

      def initialize(@tracer)
        @progress = ProgressBar.new(total: tracer.height)
      end

      abstract def call : Array(Array(Pixel))

      def step
        progress.inc
      end

      def finish
        progress.done unless progress.done?
      end
    end
  end
end

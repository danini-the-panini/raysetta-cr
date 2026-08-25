require "../pixel"

module Raysetta
  module Output
    abstract class Base
      property pixels : Array(Array(Pixel))
      property width : Int32
      property height : Int32

      def initialize(@pixels, @width, @height)
      end

      abstract def call

      def save(file)
        File.write(file, call)
      end
    end
  end
end

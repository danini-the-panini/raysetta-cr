require "wait_group"

require "./base"

module Raysetta
  module Runner
    class Fibers < Base
      property count : Int32

      def initialize(tracer, @count = System.cpu_count)
        super(tracer)
      end

      def call : Array(Array(Pixel))
        mosi = Channel(Int32).new
        miso = Channel(Tuple(Int32, Array(Pixel))).new
        err_child = Channel(::Exception).new
        err_parent = Channel(::Exception).new
        wg = WaitGroup.new(count+1)
        Array.new(count) do |i|
          Fiber::ExecutionContext::Isolated.new("worker #{i}") do
            loop do
              select
              when y = mosi.receive?
                begin
                  break unless y
                  row = Array.new(@tracer.width) do |x|
                    @tracer.call(x, y)
                  end
                  miso.send({y, row})
                rescue ex
                  err_child.send(ex)
                  break
                end
              end
            end
            wg.done
          end
        end

        output = Array(Array(Pixel)).new(tracer.height) { [] of Pixel }
        spawn do
          @tracer.height.times do
            select
            when input = miso.receive?
              break unless input
              y, row = input
              output[y] = row
              step
            when ex = err_child.receive
              err_parent.send(ex)
              break
            end
          end
          miso.close
          mosi.close
          wg.done
        end

        tracer.height.times do |y|
          select
          when mosi.send(y)
          when ex = err_parent.receive
            raise ex
          end
        end

        wg.wait

        finish
        output
      end
    end
  end
end

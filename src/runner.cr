require "./scene"
require "./tracer"
require "./runner/base"
require "./runner/sync"
require "./runner/fibers"
require "./output/base"
require "./output/ppm"
require "./output/png"

module Raysetta
  module Runner
    def self.parse_scene(input_path, output_path = nil, runner = :sync, format = :ppm, concurrency : Int32 = System.cpu_count, width = 256, height = 256, samples_per_pixel = 10, max_depth = 10)
      scene = Raysetta::Scene.parse(Hash(String, JSON::Any).from_json(File.read(input_path)))

      tracer = Raysetta::Tracer.new(scene, width, height, samples_per_pixel, max_depth)
      runner_obj = case runner
      when :sync then Raysetta::Runner::Sync.new(tracer)
      when :fibers then Raysetta::Runner::Fibers.new(tracer, count: concurrency)
      else
        STDERR.puts "*** Unknown runner #{runner} ***"
        exit
      end
      runner_output = runner_obj.call
      output = case format
      when :ppm then Raysetta::Output::PPM.new(runner_output, width: tracer.width, height: tracer.height)
      when :png then Raysetta::Output::PNG.new(runner_output, width: tracer.width, height: tracer.height)
      else
        STDERR.puts "*** Unknown format #{format} ***"
        exit
      end
      if output_path
        output.save(output_path)
      else
        puts output.call
      end
    end
  end
end

module Raysetta
  VERSION = "0.1.0"
end

require "option_parser"

format_opt : String? = nil
concurrency_opt : Int32? = nil
output_path : String? = nil
width_opt = 256
height_opt = 256
samples_opt = 10
depth_opt = 10

opts_parser = OptionParser.parse do |opts|
  opts.banner = "Usage: raysetta FILE [options]"

  opts.on("-w", "--width WIDTH", "Image width (default 256)") do |width|
    width_opt = width.to_i
  end
  opts.on("-h", "--height HEIGHT", "Image height (default 256)") do |height|
    height_opt = height.to_i
  end
  opts.on("-s", "--samples SAMPLES", "Samples per pixel (default 10)") do |samples|
    samples_opt = samples.to_i
  end
  opts.on("-d", "--depth DEPTH", "Max depth (default 10)") do |depth|
    depth_opt = depth.to_i
  end

  opts.on("-f", "--format FORMAT", "Output format (ppm, png; default ppm)") do |format|
    format_opt = format
  end
  opts.on("-c", "--concurrency CONCURRENCY", "Concurrency (defaults to number of CPUs)") do |concurrency|
    concurrency_opt = concurrency.to_i
  end
  opts.on("-o", "--output FILE", "Output file (default STDOUT)") do |output|
    output_path = output
  end

  opts.on("--help", "Show this message") do
    puts opts
    exit
  end

  opts.on("-v", "--version", "Show version") do
    puts Raysetta::VERSION
    exit
  end
end

require "./raysetta"
require "./runner"

if ARGV.size < 1
  STDERR.puts "*** Missing FILE_OR_URL argument ***"
  puts opts_parser
  exit
end

file_or_url = ARGV.first

runner = :fibers
concurrency = System.cpu_count
if c = concurrency_opt
  concurrency = c
  runner = :sync if c == 1
end

format = case format_opt
when "png" then :png
when "ppm" then :ppm
when nil then :ppm
else
  STDERR.puts "*** Unknown output format #{format_opt.inspect}, defaulting to ppm"
  :ppm
end

if output_path.nil? && format_opt == :png
  STDERR.puts "*** Refusing to output PNG to STDOUT ***"
  exit
end

Raysetta::Runner.parse_scene(
  file_or_url,
  output_path,
  runner,
  format,
  concurrency,
  width_opt,
  height_opt,
  samples_opt,
  depth_opt
)

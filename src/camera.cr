require "./vec3"
require "./ray"

module Raysetta
  class Camera
    property vfov : Float64  # Vertical view angle (field of view)
    property lookfrom : Vec3 # Point camera is looking from
    property lookat : Vec3   # Point camera is looking at
    property vup : Vec3      # Camera-relative "up" direction

    property defocus_angle : Float64 # Variation angle of rays through each pixel
    property focus_dist : Float64     # Distance from camera lookfrom point to plane of perfect focus

    def initialize(
      @vfov = 90.0,
      @lookfrom = Vec3.new(0.0, 0.0, 0.0),
      @lookat = Vec3.new(0.0, 0.0, -1.0),
      @vup = Vec3.new(0.0, 1.0, 0.0),
      @defocus_angle = 0.0,
      @focus_dist = 10.0
    )
      @image_height = 0
      @center = Vec3.new(0.0, 0.0, 0.0)
      @pixel00_loc = Vec3.new(0.0, 0.0, 0.0)
      @pixel_delta_u = Vec3.new(0.0, 0.0, 0.0)
      @pixel_delta_v = Vec3.new(0.0, 0.0, 0.0)
      @u = Vec3.new(0.0, 0.0, 0.0)
      @v = Vec3.new(0.0, 0.0, 0.0)
      @w = Vec3.new(0.0, 0.0, 0.0)
      @defocus_disk_u = Vec3.new(0.0, 0.0, 0.0)
      @defocus_disk_v = Vec3.new(0.0, 0.0, 0.0)
    end

    def viewport(image_width, image_height)
      @image_height = image_height
      aspect_ratio = image_width.to_f / image_height.to_f

      @center = lookfrom

      # Determine viewport dimensions.
      theta = Util.degrees_to_radians(vfov)
      h = Math.tan(theta / 2.0)
      viewport_height = 2.0 * h * focus_dist
      viewport_width = viewport_height * aspect_ratio

      # Calculate the u,v,w unit basis vectors for the camera coordinate frame.
      @w = (lookfrom - lookat).normalize
      @u = vup.cross(w).normalize
      @v = w.cross(u)

      # Calculate the vectors across the horizontal and down the vertical viewport edges.
      viewport_u = u * viewport_width   # Vector across viewport horizontal edge
      viewport_v = -v * viewport_height # Vector down viewport vertical edge

      # Calculate the horizontal and vertical delta vectors from pixel to pixel.
      @pixel_delta_u = viewport_u / image_width.to_f
      @pixel_delta_v = viewport_v / image_height.to_f

      # Calculate the location of the upper left pixel.
      viewport_upper_left =
          center - (w*focus_dist) - viewport_u.div(2.0) - viewport_v.div(2.0)
      @pixel00_loc = viewport_upper_left.add((pixel_delta_u + pixel_delta_v).mul(0.5))

      # Calculate the camera defocus disk basis vectors.
      defocus_radius = focus_dist * Math.tan(Util.degrees_to_radians(defocus_angle / 2.0))
      @defocus_disk_u = u * defocus_radius
      @defocus_disk_v = v * defocus_radius
    end

    # Construct a camera ray originating from the defocus disk and directed at a randomly
    # sampled point around the pixel location x, y.
    def ray(x, y)
      offset = Vec2.sample_square
      pixel_sample = pixel00_loc +
                        (pixel_delta_u * (x + offset.x)) +
                        (pixel_delta_v * (y + offset.y))

      ray_origin = defocus_angle <= 0 ? center : defocus_disk_sample
      ray_direction = pixel_sample - ray_origin
      ray_time = rand

      Ray.new(ray_origin, ray_direction, ray_time)
    end

    def export
      {
        vfov: vfov,
        lookfrom: lookfrom.to_a,
        lookat: lookat.to_a,
        vup: vup.to_a,
        defocus_angle: defocus_angle,
        focus_dist: focus_dist
      }
    end

    private property image_height : Int32  # Rendered image height
    private property center : Vec3         # Camera center
    private property pixel00_loc : Vec3    # Location of pixel 0, 0
    private property pixel_delta_u : Vec3  # Offset to pixel to the right
    private property pixel_delta_v : Vec3  # Offset to pixel below

    # Camera frame basis vectors
    private property u : Vec3
    private property v : Vec3
    private property w : Vec3

    private property defocus_disk_u : Vec3 # Defocus disk horizontal radius
    private property defocus_disk_v : Vec3 # Defocus disk vertical radius

    # Returns a random point in the camera defocus disk.
    private def defocus_disk_sample
      v = Vec3.random_in_unit_disk
      center + (defocus_disk_u * v.x) + (defocus_disk_v * v.y)
    end
  end
end

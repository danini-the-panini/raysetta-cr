require "json"
require "./exception"
require "./util"
require "./vec2"
require "./vec3"
require "./camera"
require "./perlin"
require "./image"
require "./texture/solid_color"
require "./texture/checker"
require "./texture/image"
require "./texture/noise"
require "./material/lambertian"
require "./material/metal"
require "./material/dielectric"
require "./material/diffuse_light"
require "./object/sphere"
require "./object/moving_sphere"
require "./object/quad"
require "./object/tri"
require "./object/box"
require "./object/bvh"
require "./background/solid"
require "./background/gradient"
require "./background/cube_map"
require "./background/sphere_map"

module Raysetta
  class Scene
    property world : Object3D
    property camera : Camera
    property background : Background

    def initialize(@world, @camera, @background)
    end

    def self.parse(json)
      Parser.new(json).parse
    end

    def export
      all_materials = world.materials
      all_textures = [*all_materials, background].flat_map(&:textures).uniq!
      all_images = all_textures.flat_map(&:images).uniq!
      all_noises = all_textures.flat_map(&:noises).uniq!
      {
        world: world.export,
        camera: camera.export,
        background: background.export,
        materials: export_by_id(all_materials),
        textures: export_by_id(all_textures),
        images: export_by_id(all_images),
        noises: export_by_id(all_noises)
      }
    end

    private def export_by_id(entities)
      exported = {} of String => Hash(Symbol, JSON::Any)
      entities.each do |entity|
        exported[entity.id] = entity.export
      end
      exported
    end

    class Parser
      class Exception < Raysetta::Exception; end

      getter json : Hash(String, JSON::Any)

      def initialize(@json)
        @noises = {} of String => Perlin
        @images = {} of String => Image
        @textures = {} of String => Texture
        @materials = {} of String => Material
      end

      def parse
        @noises = json["noises"].as_h.transform_values { |val| parse_noise(val) }
        @images = json["images"].as_h.transform_values { |val| parse_image(val) }
        @textures = json["textures"].as_h.transform_values { |val| parse_texture(val) }
        @materials = json["materials"].as_h.transform_values { |val| parse_material(val) }
        world = parse_world(json["world"].as_h)
        camera = parse_camera(json["camera"].as_h)
        background = parse_background(json["background"])

        Scene.new(world, camera, background)
      end

      def parse_noise(noise) : Perlin
        Perlin.new(
          noise["randvec"].as_a.map { |v| vec3(v) },
          noise["perm_x"].as_a.map(&.as_i),
          noise["perm_y"].as_a.map(&.as_i),
          noise["perm_z"].as_a.map(&.as_i)
        )
      end

      def parse_image(img)
        Image.new(data_url: img["data"].as_s)
      end

      def parse_texture(tex)
        case tex["type"].as_s
        when "SolidColor" then Texture::SolidColor.new(rgb(tex["albedo"]))
        when "Checker" then Texture::Checker.new(tex["scale"].as_f, parse_texture(tex["even"]), parse_texture(tex["odd"]))
        when "Image" then Texture::Image.new(image(tex["image"]))
        when "Noise" then Texture::Noise.new(tex["scale"].as_f, tex["depth"].as_i, axis(tex["marble_axis"]), noise(tex["noise"]))
        else raise Exception.new("unknown texture type #{tex["type"]}")
        end
      end

      def parse_material(mat)
        case mat["type"]
        when "Lambertian" then Material::Lambertian.new(texture(mat["texture"]))
        when "Metal" then Material::Metal.new(texture(mat["texture"]), mat["fuzz"].as_f)
        when "Dielectric" then Material::Dielectric.new(mat["refraction_index"].as_f)
        when "DiffuseLight" then Material::DiffuseLight.new(texture(mat["texture"]))
        else raise Exception.new("unknown material type #{mat["type"]}")
        end
      end

      def parse_world(json : Hash(String, JSON::Any))
        Object3D::BVH.new(json.map { |_, v| parse_object(v) })
      end

      def parse_object(obj)
        case obj["type"]
        when "Sphere" then parse_sphere(obj)
        when "MovingSphere" then parse_moving_sphere(obj)
        when "Quad" then parse_quad(obj)
        when "Tri" then parse_tri(obj)
        when "Box" then parse_box(obj)
        else raise Exception.new("unknown object type #{obj["type"]}")
        end
      end

      def parse_sphere(obj)
        Object3D::Sphere.new(vec3(obj["center"]), obj["radius"].as_f, material(obj["material"]))
      end

      def parse_moving_sphere(obj)
        Object3D::MovingSphere.new(vec3(obj["center1"]), vec3(obj["center2"]), obj["radius"].as_f, material(obj["material"]))
      end

      def parse_quad(obj)
        Object3D::Quad.new(vec3(obj["q"]), vec3(obj["u"]), vec3(obj["v"]), material(obj["material"]))
      end

      def parse_tri(obj)
        Object3D::Tri.new(vec3(obj["a"]), vec3(obj["b"]), vec3(obj["c"]), material(obj["material"]))
      end

      def parse_box(obj)
        Object3D::Box.new(vec3(obj["a"]), vec3(obj["b"]), material(obj["material"]))
      end

      def material(name)
        raise Exception.new("unknown material #{name}") unless @materials[name]?

        @materials[name]
      end

      def texture(name)
        raise Exception.new("unknown texture #{name}") unless @textures[name]?

        @textures[name]
      end

      def image(name)
        raise Exception.new("unknown image #{name}") unless @images[name]?

        @images[name]
      end

      def noise(name)
        raise Exception.new("unknown noise #{name}") unless @noises[name]?

        @noises[name]
      end

      def parse_camera(cam)
        camera = Camera.new
        camera.vfov = cam["vfov"].as_f if cam["vfov"]?
        camera.lookfrom = vec3(cam["lookfrom"]) if cam["lookfrom"]?
        camera.lookat = vec3(cam["lookat"]) if cam["lookat"]?
        camera.vup = vec3(cam["vup"]) if cam["vup"]?
        camera.defocus_angle = cam["defocus_angle"].as_f if cam["defocus_angle"]?
        camera.focus_dist = cam["focus_dist"].as_f if cam["focus_dist"]?
        camera
      end

      def parse_background(bg)
        case bg["type"]
        when "Solid" then parse_solid_bg(bg)
        when "Gradient" then parse_gradient_bg(bg)
        when "SphereMap" then parse_sphere_map(bg)
        when "CubeMap" then parse_cube_map(bg)
        else raise Exception.new("unknown background type #{bg["type"]}")
        end
      end

      def parse_solid_bg(bg)
        Background::Solid.new(rgb(bg["albedo"]))
      end

      def parse_gradient_bg(bg)
        Background::Gradient.new(rgb(bg["top"]), rgb(bg["bottom"]))
      end

      def parse_sphere_map(bg)
        Background::SphereMap.new(texture(bg["texture"]))
      end

      def parse_cube_map(bg)
        Background::CubeMap.new(bg["textures"].as_a.map { |tex| texture(tex) })
      end

      def vec3(e)
        Vec3.new(e[0].as_f, e[1].as_f, e[2].as_f)
      end
      alias_method :rgb, :vec3

      def vec2(e)
        Vec2.new(e[0].as_f, e[1].as_f)
      end

      def axis(a)
        s = a.as_s?
        case s
        when "x" then :x
        when "y" then :y
        when "z" then :z
        else raise Exception.new("unknown axis #{s}")
        end
      end
    end
  end
end

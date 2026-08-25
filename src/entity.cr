module Raysetta
  class Entity
    def id
      "#{type.downcase}-#{object_id.to_s(16)}"
    end

    def type
      self.class.name.split("::").last
    end

    def ==(other)
      other.class == self.class && id == other.id
    end

    def hash
      id.hash
    end

    def export
      {
        type: type
      }
    end
  end
end

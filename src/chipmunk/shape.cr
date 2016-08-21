module CP
  abstract class Shape
    abstract def to_unsafe : LibCP::Shape

    # :nodoc:
    def self.from(this : LibCP::Shape*) : self
      LibCP.shape_get_user_data(this).as(self)
    end
    # :nodoc:
    def self.from?(this : LibCP::Shape*) : self?
      self.from(this) if this
    end

    def finalize
      LibCP.shape_destroy(self)
    end

    def cache_bb() : BB
      LibCP.shape_cache_bb(self)
    end

    def update(transform : Transform) : BB
      LibCP.shape_update(self, transform)
    end

    def point_query(p : Vect) : PointQueryInfo
      LibCP.shape_point_query(self, p, out info)
      info
    end

    def segment_query(a : Vect, b : Vect, radius : Number) : SegmentQueryInfo
      LibCP.shape_segment_query(self, a, b, radius, out info)
      info
    end

    def collide(b : Shape) : ContactPointSet
      LibCP.shapes_collide(self, b)
    end

    def space : Space?
      Space.from?(LibCP.shape_get_space(self))
    end

    def body : Body?
      Body.from?(LibCP.shape_get_space(self))
    end
    def body=(body : Body?)
      LibCP.shape_set_body(self, body)
    end

    def mass : Float64
      LibCP.shape_get_mass(self)
    end
    def mass=(mass : Number)
      LibCP.shape_set_mass(self, mass)
    end

    def density : Float64
      LibCP.shape_get_density(self)
    end
    def density=(density : Number)
      LibCP.shape_set_density(self, density)
    end

    def moment() : Float64
      LibCP.shape_get_moment(self)
    end

    def area() : Float64
      LibCP.shape_get_area(self)
    end

    def center_of_gravity() : Vect
      LibCP.shape_get_center_of_gravity(self)
    end

    def bb() : BB
      LibCP.shape_get_bb(self)
    end

    def sensor? : Bool
      LibCP.shape_get_sensor(self)
    end
    def sensor=(sensor : Bool)
      LibCP.shape_set_density(self, sensor)
    end

    def elasticity : Float64
      LibCP.shape_get_elasticity(self)
    end
    def elasticity=(elasticity : Number)
      LibCP.shape_set_elasticity(self, elasticity)
    end

    def friction : Float64
      LibCP.shape_get_friction(self)
    end
    def friction=(friction : Number)
      LibCP.shape_set_friction(self, friction)
    end

    def surface_velocity : Vect
      LibCP.shape_get_surface_velocity(self)
    end
    def surface_velocity=(surface_velocity : Vect)
      LibCP.shape_set_surface_velocity(self, surface_velocity)
    end

    def collision_type : LibCP::CollisionType
      LibCP.shape_get_collision_type(self)
    end
    def collision_type=(collision_type : LibCP::CollisionType)
      LibCP.shape_set_collision_type(self, collision_type)
    end

    def filter : ShapeFilter
      LibCP.shape_get_filter(self)
    end
    def filter=(filter : ShapeFilter)
      LibCP.shape_set_filter(self, filter)
    end
  end

  class CircleShape < Shape
    def initialize(body : Body, radius : Number, offset : Vect)
      @shape = uninitialized LibCP::CircleShape
      LibCP.circle_shape_init(pointerof(@shape), body, radius, offset)
      LibCP.shape_set_user_data(self, self.as(Void*))
    end

    # :nodoc:
    def to_unsafe : LibCP::Shape*
      pointerof(@shape).as(LibCP::Shape*)
    end

    def offset : Vect
      LibCP.circle_shape_get_offset(self)
    end

    def radius : Float64
      LibCP.circle_shape_get_radius(self)
    end
  end

  class SegmentShape < Shape
    def initialize(body : Body, a : Vect, b : Vect, radius : Number)
      @shape = uninitialized LibCP::SegmentShape
      LibCP.segment_shape_init(pointerof(@shape), body, a, b, radius)
      LibCP.shape_set_user_data(self, self.as(Void*))
    end

    # :nodoc:
    def to_unsafe : LibCP::Shape*
      pointerof(@shape).as(LibCP::Shape*)
    end

    def a : Vect
      LibCP.segment_shape_get_a(self)
    end
    def b : Vect
      LibCP.segment_shape_get_b(self)
    end

    def normal() : Vect
      LibCP.segment_shape_get_normal(self)
    end

    def radius : Float64
      LibCP.segment_shape_get_radius(self)
    end
  end

  class PolyShape < Shape
    include Enumerable(Vect)
    include Indexable(Vect)

    def initialize(body : Body, verts : Array(Vert)|Slice(Vert), transform : Transform, radius : Number)
      @shape = uninitialized LibCP::PolyShape
      LibCP.poly_shape_init(pointerof(@shape), body, verts.size, verts, transform, radius)
      LibCP.shape_set_user_data(self, self.as(Void*))
    end
    def initialize(body : Body, verts : Array(Vert)|Slice(Vert), radius : Number)
      @shape = uninitialized LibCP::PolyShape
      LibCP.poly_shape_init_raw(pointerof(@shape), body, verts.size, verts, radius)
      LibCP.shape_set_user_data(self, self.as(Void*))
    end

    # :nodoc:
    def to_unsafe : LibCP::Shape*
      pointerof(@shape).as(LibCP::Shape*)
    end

    def size : Int32
      LibCP.poly_shape_get_count(self)
    end

    def [](index : Int32) : Vect
      LibCP.poly_shape_get_vect(self, index)
    end

    def radius : Float64
      LibCP.poly_shape_get_radius(self)
    end
  end

  class BoxShape < PolyShape
    def initialize(body : Body, width : Number, height : Number, radius : Number)
      @shape = uninitialized LibCP::PolyShape
      LibCP.box_shape_init(pointerof(@shape), body, width, height, radius)
      LibCP.shape_set_user_data(self, self.as(Void*))
    end
    def initialize(body : Body, box : BB, radius : Number)
      @shape = uninitialized LibCP::PolyShape
      LibCP.box_shape_init(pointerof(@shape), body, box, radius)
      LibCP.shape_set_user_data(self, self.as(Void*))
    end
  end
end

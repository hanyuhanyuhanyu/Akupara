module Akupara
  class Direction
    def self.dirs
      @directions
    end
    def self.set_def(type = :square) 
      @directions = dir_def(type)
      Direction.dirs.each_with_index{|dir,ind|
        define_method(dir){Direction.dirs[(@index+ind) % Direction.dirs.length]}
      }
    end
    def self.dir_def(type = :square)
      square_def = %i|up right_up right right_down down left_down left left_up|
      return case type 
      when :square
        square_def
      when :hexagon
        square_def.reject{|i| %i|right left|.include? i}
      end
    end

    set_def(:square)

    def initialize(direction = :up,type = nil)
      Direction.set_def(type) if type
      @index = Direction.dirs.index(direction)
    end
    def clockwise(times = 1)
      @index += times
      @index %= Direction.dirs.length
      self
    end
    def dirs 
      Direction.dirs
    end
  end
end

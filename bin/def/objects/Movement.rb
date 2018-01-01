module Akupara
  class Movement
    def initialize(move_hash)
      @moves = []
      move_hash.each_pair{|key,val|
        if val == "all"
          @moves = [key.to_sym].cycle
        else
          @moves << [key.to_sym]*val
        end
      }
      @moves.flatten! if @moves.is_a?(Array)
    end
    def to_a
      @moves
    end
  end
  class Moveables
    def initialize(move_def)
      @movables = [define_movement(move_def)].flatten.map(&:to_a)
    end
    def define_movement(value)
      return case value
      when Array 
        value.map{|i| define_movement(i)}
      when String 
        Movement.new({value.to_sym => 1})
      when Hash  
        Movement.new(value)
      end
    end
  end
end

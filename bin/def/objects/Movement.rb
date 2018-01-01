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
    attr_reader :movables
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
    def movable?(start,goal,dir,&block)
      block = ->(*_){false} unless block_given?
      list_movables(start,dir,&block).include? goal
    end
    def list_movables(place,dir,&block)
      block = ->(*_){false} unless block_given?
      @movables.map{|moves|
        case moves
        when Enumerator
          search = place
          [].tap{|c|
            moves.each{|m|
              m = dir.send(m)
              break unless search.send(m)
              search = search.send(m)
              break if block.call(search)
              c << search
            }
            break c
          }
        when Array  
          apply_all_move(place,moves.map{|m| dir.send m},&block)
        end
      }.flatten
    end
    def apply_all_move(place,arr,&block)
      block = ->(*_){false} unless block_given?
      return nil unless place.send arr.first
      return place.send(arr.first) if arr.length <= 1 || block.call(place)
      apply_all_move(place.send(arr.first),arr.drop(1),&block)
    end
    def list_reachables(start,dir)
      flag = false 
      list_movables(start,dir){|p|
        buf = flag
        flag = !!p.placing
        buf
      }
    end
    def list_stayables(start,dir)
      flag = false
      list_movables(start,dir){|p| 
        buf = flag
        flag = !!p.placing
        buf || p.placing && p.placing&.ally == start.placing&.ally
      }
    end
  end
end

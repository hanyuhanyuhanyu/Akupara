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
    def apply_moves(moves,start,dir,&block)
      return case moves
      when Enumerator
        apply_enumerator(start,moves.lazy.map{|m| dir.send m},&block)
      when Array  
        apply_all_move(start,moves.map{|m| dir.send m})
      end
    end
    def route(start,goal,dir)
      @movables.map{|moves|
        way = apply_moves(moves,start,dir)
        way&.include?(goal) ? way.take_while{|p| p != goal} : []
      }.reject(&:empty?).flatten
    end
    def list_movables(start,dir,&block)
      block = ->(*_){false} unless block_given?
      @movables.map{|moves|
        apply_moves(moves,start,dir,&block)
      }.flatten.reject(&:nil?)
    end
    def apply_enumerator(place,enum,&block)
      search = place
      return [].tap{|c|
        enum.each{|m|
          search = search&.send(m)
          break if block_given? && block.call(search)
          break unless search
          c << search
        }
        break c
      }
    end
    def apply_all_move(place,arr)
      return nil unless place || arr.length < 1
      return place.send(arr.first) if arr.length == 1
      apply_all_move(place.send(arr.first),arr.drop(1))
    end
    def list_reachables(start,dir)
      flag = false 
      list_movables(start,dir){|p|
        flag = false unless p
        buf = flag
        flag = !!p&.placing && !flag
        buf
      }
    end
    def list_stayables(start,dir)
      list_reachables(start,dir).reject{|p| p.placing && p.placing.ally == start.placing.ally}
    end
  end
end

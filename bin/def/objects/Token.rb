require 'json'
module Akupara 
  class Token
    inherit_basics
    attr_reader :name , :subtype , :amount
    def initialize(key , value = {})
      @to_sym = key.to_sym
      @name = value["name"]
      @num = 1
      @ally = nil
      @dir = Direction.new
    end
    def init(amo = nil)
      case amo
      when Hash 
        amo.each_pair do |key,value|
          value.times{hold(eval "#{key.to_s.capitalize}.new")}
        end
      when Integer
        @num = amo
      end
    end
    def add(num = 1)
      @num += num
    end
    def reduce(num = 1)
      @num -= num
      nil if @num <= 0
    end
    def clockwise(times = 1) 
      @dir.clockwise(times) 
    end
    def movable?(place) 
      return true unless @movables    
      return @movables.each{|movable|
        search = @where.clone 
        result = movable.each{|direction|
          break false unless search.send(direction)
          break true if search.send(direction) == place
          search = search.send(direction)
        }
        break result.eql? true
      }
    end
  end

  class TokenHolder < Hash
    def setup(*token)
      token.flatten.each{|token| self[token] = eval "#{token.to_s.capitalize}.new(init:true)"}
    end
  end

end

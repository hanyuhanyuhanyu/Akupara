require 'json'
module Akupara 
  class Token
    def self.movable
      nil
    end
    inherit_basics
    attr_reader :name , :subtype , :amount
    def initialize(key , value = {})
      @to_sym = key.to_sym
      @name = value["name"]
      @num = 1
      @ally = nil
      @dir = Direction.new
      @movable = self.class.movable
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
      return true unless @movable
      @movable.movable?(@where,place,@dir)
    end
    def list_movables
      return [] unless @movable
      @movable.list_movables(@where,@dir)
    end
    def list_reachables
      return [] unless @movable
      @movable.list_reachables(@where,@dir)
    end
    def list_stayables
      return [] unless @movable
      @movable.list_stayables(@where,@dir)
    end
    def route(place)
      return [] unless @movable
      @movable.route(@where,place,@dir)
    end
  end

  class TokenHolder < Hash
    def setup(*token)
      token.flatten.each{|token| self[token] = eval "#{token.to_s.capitalize}.new(init:true)"}
    end
  end

end

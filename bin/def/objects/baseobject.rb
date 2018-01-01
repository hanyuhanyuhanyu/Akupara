module Akupara
  module BaseInitialize
    def initialize(*args,&block)
      var_hash = {
        ally:nil,
        hold:Hash.new,
        where:nil,
        to_sym:self.class.name.downcase.to_sym,
        }
      var_hash.each_pair do |name,val|
        name = "@"+name.to_s
        instance_variable_set(name,val) unless instance_variable_get(name) 
      end
      super(*args,&block)
    end
  end
  module BaseMethods
    attr_reader :ally,:to_sym,:where
    @count = 0
    def self.addcount
      @count += 1
      @count - 1
    end
    def alight(place)
      @where&.remove if @where&.is_a?(Place)
      @where = place
      place.place self if place.is_a?(Place)
    end
    def leave
      @where&.remove
      @where = nil
    end
    def hold(token)
      if @hold[token.to_sym] && !token.is_a?(Token)
        @hold[token.to_sym].add
      else
        @hold[token.to_sym] = token
      end
    end
    def release(token)
      return unless @hold[token.to_sym]
      @hold[token.to_sym] = token.is_a?(Token) ? @hold[token.to_sym].reduce : nil 
    end
    def [](token)
      @hold[token.to_sym]
    end
    def ally_of(arg)
      @ally = (arg.is_a?(Symbol) ? arg : arg.ally)
    end
    def ally?(arg)
      return false if self.ally.nil? || arg.ally.nil?
      self.ally == arg.ally
    end
    def opponent?(arg)
      return false if self.ally.nil? || arg.ally.nil?
      !ally?(arg)
    end  
  end
end
class Class
  def inherit_basics
    self.prepend ::Akupara::BaseInitialize
    self.include ::Akupara::BaseMethods
  end 
end
require File.expand_path("../Direction.rb",__FILE__)
require File.expand_path("../Movement.rb",__FILE__)

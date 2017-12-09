require 'json'
class PlaceHolder < Hash
   def reconnect
    self.each_pair do |key , place|
      place.adjs.each do |pl|
        self[pl.to_sym]&.add_adj(key.to_sym)
      end
    end
  end
end
class DefaultBoard < PlaceHolder
  @default_dirs = %i|right_down right right_up down up left_down left left_up|
  def self.directions; @default_dirs;end
 	grid = [1,0,-1]
  @grid_defs = {
 		left_up:[grid , grid],
 		right_up:[grid.reverse , grid],
 		left_down:[grid , grid.reverse],
  	right_down:[grid.reverse , grid.reverse]
	}
  @grid_defs.each_pair{|key , val| @grid_defs[key] = val[0].product(val[1]).reject{|item| item.all?(&:zero?)}.map{|item| item.reverse}}
  def self.grid_defs;@grid_defs;end
  def initialize(row , col , setting)
    @row = row; @col = col
    origin = setting["origin"]||:left_up
    type = setting["type"]||:square
  	@grid_hash = {}
  	directions.each_with_index{|dir , ind| @grid_hash[dir] = DefaultBoard.grid_defs[origin][ind]}
    all_arr = [*0...row].product([*0...col])
    #nil cannot go here instead of 0 cause nil cannot imply that some object will be there.
    all_arr.each{|i| self[?r.+(i.join(?c)).to_sym] = 0}
    all_arr.each do |i| 
      buf_hash ={name:nil,adjs:[],diagonals:[]}
      buf_hash[:name] = ?r.+(i.join(?c))
      @grid_hash.each_pair do |key , item|
        around = ?r.+([i[0]+item[0],i[1]+item[1]].join(?c)).to_sym
        next unless self[around]
        buf_hash[key.to_s.include?("_") ? :diagonals : :adjs] << around
        buf_hash[key.to_sym] = around 
      end
      self[buf_hash[:name].to_sym] = Place.new(buf_hash[:name] , buf_hash)
    end
	end
  def [](r,c=nil)
    super(r) || super("r#{r}c#{c}".to_sym)
  end
end
def directions
  DefaultBoard.directions
end

class Place
  attr_reader :to_sym , :name , :direction , :arounds , :adjs , :diagonals , :placing
  directions.each do |dir|
    define_method(dir){@direction[dir]}
  end
  def initialize(key , value)
    @to_sym = key.to_sym
    @name = value[:name]
    @adjs = value[:adjs].map(&:to_sym)
    @diagonals = value[:diagonals].map(&:to_sym)
    @hold = {}
    @direction = {}
    @arounds = []
    @placing = nil
    directions.each do |dir|
      next unless value[dir]
      @direction[dir] = value[dir]
      @arounds << value[dir]
    end
  end
  def adj?(place)
    @adjs.include?(place)
  end
  def add_adj(place)
    @adjs << place unless adj?(place)
  end
  def gather(direction , &block)
    return [] unless @direction[direction]
    target = @direction[direction]
    block = ->(_){true} unless block_given?
    (block.call(target) ? [target] : []) + target.gather(direction,&block)
  end
  def method_missing(method,*args,&block)
    Places.send(method,self,*args,&block)
  end
  def place(arg)
    @placing = arg
  end
  def remove
    @placing = nil
  end
  def placed?
    !!@placing
  end
end


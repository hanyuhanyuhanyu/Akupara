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
  @default_dirs = %w|right_down right right_up down up left_down left left_up|
  def self.def_dirs; @default_dirs;end
 	grid = [1,0,-1]
  @grid_defs = {
 		"left_up" => [grid , grid],
 		"right_up" => [grid.reverse , grid],
 		"left_down" => [grid , grid.reverse],
  	"right_down" => [grid.reverse , grid.reverse]
	}
  @grid_defs.each_pair{|key , val| @grid_defs[key] = val[0].product(val[1]).reject{|item| item.all?(&:zero?)}.map{|item| item.reverse}}
  def self.grid_defs;@grid_defs;end
  def initialize(row , col , setting)
    @row = row; @col = col
    origin = setting["origin"]||"left_up";type = setting["type"]||"square"
  	directions = DefaultBoard.def_dirs
  	@grid_hash = {}
  	directions.each_with_index{|dir , ind| @grid_hash[dir] = DefaultBoard.grid_defs[origin || "left_up"][ind]}
    all_arr = [*0...row].product([*0...col])
    all_arr.each{|i| self["r#{i[0]}c#{i[1]}".to_sym] = 0}
    all_arr.each do |i| 
      buf_hash ={}
      buf_hash["name"] = "r#{i[0]}c#{i[1]}"
      buf_hash["adjs"] = []
      @grid_hash.each_pair do |key , item|
        arr = [i[0]+item[0],i[1]+item[1]]
        next unless self["r#{arr[0]}c#{arr[1]}".to_sym]
        buf_hash["adjs"] << "r#{arr[0]}c#{arr[1]}" unless key.include?("_")
        buf_hash[key] = "r#{arr[0]}c#{arr[1]}" 
      end
      self["r#{i[0]}c#{i[1]}".to_sym] = Place.new(buf_hash["name"] , buf_hash)
    end
	end
  def [](r,c=nil)
    super(r) || super("r#{r}c#{c}".to_sym)
  end
  def gather(place , direction , &block)
    return [] unless place
    target = self[place].send(direction)&.to_sym
    block = ->(_){true} unless block_given?
    (block.call(self[place]) ? [self[place]] : []) + self.gather(target,direction,&block)
  end
end
class Place
  attr_reader :to_sym , :name , :adjs , :arounds , :direction
  DefaultBoard.def_dirs.each do |dir|
    define_method(dir.to_sym){@direction[dir.to_sym]&.to_sym}
  end
  def initialize(key , value)
    @to_sym = key.to_sym
    @name = value["name"]
    @adjs = value["adjs"]&.reject{|val| val == ""}.uniq.map(&:to_sym)
    @holding = {}
    @direction = {}
    @arounds = []
    DefaultBoard.def_dirs.each do |dir|
      next unless value[dir]
      @direction[dir.to_sym] = value[dir].to_sym 
      @arounds << value[dir].to_sym 
    end
  end
  def parachute(place)
    warn "Warning:It is not recommended that instance of Place do 'parachute' cause it should be parahuted."
    super(place)
  end        
  def adj?(place)
    @adjs.include?(place)
  end
  def add_adj(place)
    @adjs << place unless adj?(place)
  end
  def method_missing(method,*args,&block)
    begin
      Places.send(method,self.to_sym,*args,&block)
    rescue NoMethodError
      raise NoMethodError.new("undefined method '#{method.to_s}' for #{self} and #{Places.class} (NoMethodError)")
    end
  end
end
PlaceDef = "#{File.expand_path('../def/Place.json',__FILE__)}"
PlaceJson = JSON.parse(File.open(PlaceDef,"r").read)
Places = if PlaceJson["default_board"]  
    setting = PlaceJson["default_board"]
    DefaultBoard.new(setting["row"],setting["col"],setting)
  else
  PlaceJson.each_pair do |key,value|
    eval <<-EOS
      #{key.capitalize} = Place.new('#{key}',#{value})
      Places[:#{key.to_sym}] = #{key.capitalize}
    EOS
  end
end
Places.reconnect
class Array
  def carve(&block)
    cnt = 0
    self.each do |n|
      break if yield(n)
      cnt += 1
    end
    [self[0..cnt]] + (self[cnt+1] ? self[cnt+1..-1].carve(&block) : [])
  end
end
p [1,2,3,4,5,6].carve{|n|n%2 == 0}
p Places[0,1].gather(:right_down).map(&:to_sym)

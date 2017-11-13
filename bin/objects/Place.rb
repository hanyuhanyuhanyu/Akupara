require 'json'
class Place
  attr_reader :name , :adjs

  def initialize(key , value)
    @to_sym = key.to_sym
    @name = value["name"]
    @adjs = value["adjs"]&.reject{|val| val == ""}.uniq.map(&:to_sym)
    @holding = {}
    @direction = {}
    DefaultBoard.def_dirs.each do |dir|
      @direction[dir.to_sym] = value[dir].to_sym if value[dir]
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
end
class PlaceHolder < Hash
   def reconnect
    self.each_pair do |key , place|
      place.adjs.each do |pl|
        self[pl.to_sym].add_adj(key.to_s)
      end
    end
  end
end
class DefaultBoard < Hash
  @default_dirs = %w|right_down right right_up down up left_down left left_up|
  def self.def_dirs; @default_dirs;end
	def initialize(row , col , origin = "left_up")
    @row = row; @col = col
  	directions = DefaultBoard.def_dirs
  	grid = [1,0,-1]
    grid_defs = {
  		"left_up" => [grid , grid],
  		"right_up" => [grid.reverse , grid],
  		"left_down" => [grid , grid.reverse],
  		"right_down" => [grid.reverse , grid.reverse]
  	}
  	grid_defs.each_pair{|key , val| grid_defs[key] = val[0].product(val[1]).reject{|item| item.all?(&:zero?)}}
  	@grid_hash = {}
  	directions.each_with_index{|dir , ind| @grid_hash[dir] = grid_defs[origin || "left_up"][ind]}
        
    all_arr = [*0...row].product([*0...col])
    all_arr.each{|i| self["r#{i[0]}c#{i[1]}".to_sym] = 0}
    all_arr.each do |i| 
      buf_hash ={}
      buf_hash["name"] = "r#{i[0]}c#{i[1]}"
      buf_hash["adjs"] = []
      @grid_hash.each_pair do |key , item|
        arr = [i[0]+item[0],i[1]+item[1]]
        p key
        next unless self["r#{arr[0]}c#{arr[1]}".to_sym]
        buf_hash["adjs"] << "r#{arr[0]}c#{arr[1]}" unless key.include?("_")
        buf_hash[key] = "r#{arr[0]}c#{arr[1]}" 
      end
      self["r#{i[0]}c#{i[1]}".to_sym] = Place.new(buf_hash["name"] , buf_hash)
    end
	end
end
hoge =DefaultBoard.new(8,8)
p hoge

Places = PlaceHolder.new
PlaceDef = "#{ __FILE__.split("/")[0..-2].join("/")}/def/Place.json"
PlaceJson = JSON.parse(File.open(PlaceDef,"r").read)
if PlaceJson["default_board"]
  board = PlaceJson["default_board"]
  err = nil
  err = "row" if board["row"].nil? || board["row"] < 1
  err = "col" if board["col"].nil? || board["col"] < 1
  raise "default_board must have 1 or more #{err}s but it only have #{board[err]}." if err
  rows = [*0...board["row"]].map{|num| "r#{num}"}
  cols = [*0...board["col"]].map{|num| "c#{num}"}
  rows.product(cols).map(&:join).each{|grid| Places[grid.to_sym] = {"name" => grid}}
  Places.each_pair do |key , val|
    row = val["name"][/r[0-9]+/][1..-1].to_i
    col = val["name"][/c[0-9]+/][1..-1].to_i
    val["right"] = "r#{row+1}c#{col}" if Places["r#{row+1}c#{col}".to_sym]
    val["left"] = "r#{row-1}c#{col}" if Places["r#{row-1}c#{col}".to_sym]
    val["up"] = "r#{row}c#{col-1}" if Places["r#{row}c#{col-1}".to_sym]
    val["down"] = "r#{row}c#{col+1}" if Places["r#{row}c#{col+1}".to_sym]
    val["down_right"] = "r#{row+1}c#{col+1}" if Places["r#{row+1}c#{col+1}".to_sym]
    val["up_right"] = "r#{row+1}c#{col-1}" if Places["r#{row+1}c#{col-1}".to_sym]
    val["down_left"] = "r#{row+1}c#{col+1}" if Places["r#{row+1}c#{col+1}".to_sym]
    val["up_left"] = "r#{row-1}c#{col-1}" if Places["r#{row-1}c#{col-1}".to_sym]
    %w|right left up down|.each do |adj|
      val["adjs"] ||= []
      next unless val[adj]
      val["adjs"] << val[adj]
    end
    Places[key] = Place.new(key , val)
  end
else
  PlaceJson.each_pair do |key,value|
    eval <<-EOS
      #{key.capitalize} = Place.new('#{key}',#{value})
      Places[:#{key.to_sym}] = #{key.capitalize}
    EOS
  end
  Places.reconnect
end

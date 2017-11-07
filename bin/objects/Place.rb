require 'json'

class Place
  attr_reader :name , :adjs

  def initialize(key , value)
    @to_sym = key.to_sym
    @name = value["name"]
    @adjs = value["adjs"].reject{|val| val == ""}.uniq.map(&:to_sym)
    @holding = {}
    @direction = {}
    %w|right left up down down_right up_right down_left up_left|.each do |dir|
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

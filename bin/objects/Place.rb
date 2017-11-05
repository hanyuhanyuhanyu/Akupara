require 'json'

class Place
  attr_reader :name , :adjs

  def initialize(key , value)
    @to_sym = key.to_sym
    @name = value["name"]
    @adjs = value["adjs"].reject{|val| val == ""}.uniq
    @holding = {}
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
JSON.parse(File.open(PlaceDef,"r").read).each_pair do |key,value|
  eval <<-EOS
    #{key.capitalize} = Place.new('#{key}',#{value})
    Places[:#{key.to_sym}] = #{key.capitalize}
  EOS
end
Places.reconnect
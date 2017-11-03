require 'json'
class Place
  attr_reader :sym , :name , :adjs
  def initialize(key , value)
    @sym = key.to_sym
    @name = value["name"]
    @adjs = value["adjs"].reject{|val| val == ""}.uniq
  end        
  def adj?(place)
    @adjs.include?(place)
  end
  def add_adj(place)
    @adjs << place unless adj?(place)
  end
end
class Places
  @places = {}
  class << self 
    attr_reader :places
    def [](arg)
      @places[arg]
    end
    def []=(key,val)
      @places[key] = val
    end
    def reconnect
      @places.each_pair do |key , place|
        place.adjs.each do |pl|
          @places[pl.to_sym]&.add_adj(key.to_s)
        end
      end
    end
  end
end
JSON.parse(File.open("Places.json","r").read).each_pair do |key,value|
  eval <<-EOS
    #{key.capitalize} = Place.new('#{key}',#{value})
    #{key.capitalize}.freeze
    Places[:#{key.to_sym}] = #{key.capitalize}
  EOS
end
Places.reconnect


p Atlanta.adjs
p Places[:sankt_peterburg].name
p Places.places.each_value{|val| p [val.name,val.adjs]}

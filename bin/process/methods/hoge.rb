class Stone
  def self.color(col)
    return case col
    when :white then White.new
    when :black then Black.new
    end
  end
  def to_sym
    :stone
  end
  def ally?(stone)
    self.class == stone.class
  end
end
module Stonemod
  def ally?(stone)
    @to_sym == stone.ally
  end
  def color
    self.class.name.downcase.to_sym
  end
  def ally
    color
  end
end
class White 
  include Stonemod
  def to_sym
    :stone
  end
  def reverse
    Black.new
  end
end
class Black
  include Stonemod
  def to_sym
    :stone
  end
  def reverse
    White.new
  end
end
class Placeble < Array
  def to_sym
    self.class.name.downcase.to_sym
  end
  def initialize(color=nil)
    @ally = color
    buf = case color
    when :black
      %i|r3c2 r2c3 r5c4 r4c5|.each{|p| self << p }
    when :white
      %i|r4c2 r5c3 r2c4 r3c5|.each{|p| self << p }
    end
    self
  end
end
class Place
  def placed?
    !!@hold&.[](:stone)
  end
  def ally
    @hold&.[](:stone)&.ally
  end
  def ally?(obj)
    return false unless self.ally || obj.ally
    self.ally == obj.ally
  end
  def reverse
    return unless @hold || @hold[:stone]
    @hold[:stone] = @hold[:stone].reverse
  end
end
class PlaceHolder
  def placeble?(place,dir=nil)
    unless dir 
      ret = false
      directions.each do |dir|
        ret = placeble?(place,dir)
        break ret if !!ret
      end
      return ret
    end
    return false if place.placed?
    stones = gather(place,dir)[1..-1].take_while(&:placed?)
    return false if stones.length < 2||stones[1..-1].none?{|p|p.ally?(stones[0])||stones[0][:stone].reverse.ally?(p)}
  end
  def reverse_arounds(place,dir=nil)
    return directions.each{|d|place.reverse_arounds d} unless dir
    place.gather(dir)[1..-1].tap{|plc| break [] if plc.none?{|p| p.ally? place}}.take_while{|p| !p.ally?(place)}.each(&:reverse)
  end
end
class Player
  def ally
    @to_sym
  end 
  def reset_placeble
    @hold[:placeble] = Placeble.new
  end
  def add_placeble(place)
    return unless @hold[:placeble]
    @hold[:placeble] << place unless @hold[:placeble].include? place
  end
  def search_placeble
    @hold[:placeble] = Placeble.new
    Places.values.reject(&:placed?).reject{|v| v.arounds.none?(&:placed?)}.each do |plc|
      directions.each do |dir|
        places = plc.gather(dir)[1..-1].take_while(&:placed?)
        next if places.length < 2
        next if places[0].ally?(self)
        next if places.map(&:ally).uniq.length < 2
        @hold[:placeble] << plc.to_sym
        break
      end
    end 
  end 
end
class Game
  def initialize
    @last_placed = nil
  end 
  def set_player
    %i|white black|.each{|col| Players.add_player(col);Players.values[-1].ally_of(col)}
  end
  def set_token
    %i|r3c3 r4c4|.each{|p|Places[p].hold White.new}
    %i|r3c4 r4c3|.each{|p|Places[p].hold Black.new}
    Players.values[0].hold Placeble.new(:white)
    Players.values[1].hold Placeble.new(:black)
  end

  def require_input
    return :count if Players.values.lazy.map{|v|v[:placeble]}.all?{|v|v == []}
    return :rotate if playing[:placeble] == []
    puts "input the place where you will place the stone like following example"
    puts "  r3c3"
    input = gets.chomp.to_sym
    unless playing[:placeble].include?(input)
      puts "you cannot place the stone on #{input}!" 
      return :require_input
    end
    @last_placed = Places[input]
  end
  def place_stone
    @last_placed.hold Stone.color(playing.ally)
    Players.values.map{|v| v[:placeble].delete @last_placed.to_sym}
  end
  def reverse
    @last_placed.reverse_arounds
    Players.values.each(&:search_placeble)
    Places.values.select(&:placed?).map(&:arounds).flatten.uniq.each do |v|
      can_place = v.placeble?
      next unless can_place
      Players[can_place].add_placeble v.to_sym
    end
    p Players
  end
  def rotate
    Players.next
    :count
  end

  def count
  end
  def praise_winner
  end 
end







class Stone < BaseObject
  prepend BaseMods
  attr_reader :color
  def initialize(ally)
    @ally = ally
  end 
  def reverse
    @ally = @ally == :white ? :black : :white
    self
  end 
end
class Place
  def placed?
    !!@hold[:stone]
  end
  def ally
    @hold[:stone]&.ally
  end
  def reverse
    return unless @hold[:stone]
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
  def search_placeble
    @hold[:placeble] = []
    Places.values.reject(&:placed?).reject{|v| v.arounds.none?(&:placed?)}.each do |plc|
      directions.each do |dir|
        places = plc.gather(dir).drop(1).take_while(&:placed?)
        next if places.length < 2 \
                || places[0].ally?(self) \
                || places.map(&:ally).uniq.length < 2
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
    %i|r3c3 r4c4|.each{|p|Places[p].hold Stone.new(:white)}
    %i|r3c4 r4c3|.each{|p|Places[p].hold Stone.new(:black)}
  end

  def require_input
    Players.values.each(&:search_placeble)
    return :close if Players.values.lazy.map{|v|v[:placeble]}.all?(&:empty?)
    return :rotate if playing[:placeble].empty?
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
    @last_placed.hold Stone.new(playing.ally)
  end
  def reverse
    @last_placed.reverse_arounds
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







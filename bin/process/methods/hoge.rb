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
    @to_sym == stone
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
  def initialize(color)
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
end
class DefaultBoard
  def placeble?(place,dir=nil)
    unless dir 
      DefaultBoard.def_dirs.each do |dir|
        return true if placeble?(place,dir)  
      end  
      return false
    end
    return false if Places[place].placed?
    gather(place,dir)[1..-1]&.take_while(&:placed?)&.map{|v|v[:stone]}.tap{|g| return (g.count{|v|v.ally?(Players.playing.ally)} >= 1 && !g[0].ally?(Players.playing.ally))}
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
    puts "input the place where you will place the stone like following example"
    puts "  r3c3"
    input = gets.chomp.to_sym
    unless Players.playing[:placeble].include?(input)
      puts "you cannot place the stone on #{input}!" 
      return :require_input
    end
    @last_placed = input
    Places[input].hold Stone.color(Players.playing.ally)
  end
  def place_stone
    pls = Players.values.map{|v| v[:placeble].delete @last_placed}
    Places[@last_placed].arounds.map{|v|Places[v]}.each{|v| p v.placeble?,v.to_sym}
  end
  def reverse
  end
  def rotate
    :count
  end

  def count
  end
  def praise_winner
  end 
end







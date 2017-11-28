class Class
  def inherit_basic_object
    self.prepend BaseMods
  end 
end 
class Stone < BaseObject
  inherit_basic_object
  attr_reader :color
  def initialize(ally)
    @ally = ally
  end 
  def reverse
    @ally = @ally == :white ? :black : :white
    self
  end 
  def show
    case ally
      when :white then "o"
      when :black then "#"
      else " "
    end
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
  def show
    @hold[:stone]&.show || " "
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
    stones = place.gather(dir).drop(1).take_while(&:placed?)
    return if stones.length < 2 \
              || place.ally?(stones[0]) \
              || stones.map(&:ally).uniq.length < 2
    stones.take_while{|p| p.opponent? place}.each(&:reverse)
  end
end
class Player
  def show
    @to_sym.to_s.capitalize + "(#{Stone.new(ally).show})"
  end
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
    show_the_board
    return :close if Players.values.lazy.map{|v|v[:placeble]}.all?(&:empty?)
    if playing[:placeble].empty?
      print "#{playing.show} cannot place a stone anywhere! skip the turn...";gets
      return :rotate 
    end
    puts "[#{playing.show} turn]"
    puts show_count.gsub(/^/,"  ")
    puts "type the place where you'd like to place the stone."
    puts "if you ganna place the stone on the grid 'r5c2', type like the example below."
    puts "#example\n52"
    begin
      input = ?r.+(gets.strip.insert(-2,?c)).to_sym
    end until (playing[:placeble].include?(input)||puts("you cannot place the stone on #{input}! type again..."))
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
  end

  def count
    result = count_each
    puts show_count(result)
    @winner = case result[:white] <=> result[:black]
      when 1 then :white
      when 0 then :draw
      else :black
    end
  end
  def praise_winner
    if @winner == :draw
      puts "draw!"
    else
      puts "#{@winner} won!"
    end
  end 

  def show_the_board
    rows = ["   "] * 2
    0.upto(7){|n| rows[0] += "c ";rows[1] += "#{n} "}
    rows = [rows.join("\n")+("\n")]
    0.upto(7) do |num|
      rows << "r#{num}|" + Places.values[num*8...(num+1)*8].map(&:show).join("|") + "|\n"
    end
    row_line = "  " + "-"*(8*2+1) + "\n"
    puts rows.join(row_line) + row_line
  end
  def count_each
    {white:0,black:0}.tap do |counter|
      Places.values.each{|plc| next if plc.ally.nil?; counter[plc.ally] += 1}
    end
  end
  def show_count(inp = nil)
    inp ||= count_each
    inp.map{|key,val| "#{key.to_s} => #{val}"}.join "\n"
  end
end







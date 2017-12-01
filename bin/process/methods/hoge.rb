class Stone
  inherit_basics
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
  def ally
    @placing&.ally
  end
  def reverse
    @placing.reverse if placed?
  end
  def show
    @placing&.show || " "
  end 
  def placeble?(aly,direction=nil)
    unless direction 
      ret = false
      directions.each do |dir|
        ret = placeble?(aly,direction)
        break ret if !!ret
      end
    end
    return false if placed?
    places = gather(direction).drop(1).take_while(&:placed?)
    places.map(&:ally).uniq.length >= 2 && aly.opponent?(places[0]) 
  end
  def reverse_arounds(ally,dir=nil)
    return directions.each{|d|reverse_arounds ally,d} unless dir
    return unless placeble?(ally,dir)
    gather(dir).drop(1).take_while{|p| p.opponent? ally}.each(&:reverse)
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
        next unless plc.placeble?(self,dir)
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
    %i|r3c3 r4c4|.each{|p|Places[p].place Stone.new(:white)}
    %i|r3c4 r4c3|.each{|p|Places[p].place Stone.new(:black)}
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
      input = [?r,?c,""].zip(gets.strip.each_char).join.to_sym
    end until (playing[:placeble].include?(input)||puts("you cannot place the stone on #{input}! type again..."))
    @last_placed = Places[input]
  end
  def reverse
    @last_placed.reverse_arounds(playing)
  end
  def place_stone
    @last_placed.place Stone.new(playing.ally)
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







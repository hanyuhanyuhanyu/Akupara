class Player
  @pl_num = 0
  def initialize(sym = ("pl_" + Player.add_pl_num.to_s).to_sym)
    @to_sym = sym
  end
  def self.add_pl_num
    @pl_num += 1
    @pl_num - 1
  end
end
class PlayerHolder < Hash
  attr_reader :playing
  def initialize
    @playing = nil
  end
  def add_player(name = nil)
    pl = name ? Player.new(name) : Player.new
    self[pl.to_sym] = pl
    @playing ||= self[self.keys[0]] 
  end
  def next
    @playing = values[(values.index(@playing)+1) % length]
  end
end
Players = PlayerHolder.new
def playing
  Players.playing
end
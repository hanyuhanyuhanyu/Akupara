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

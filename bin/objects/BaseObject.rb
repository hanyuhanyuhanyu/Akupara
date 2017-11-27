class BaseObject
  attr_reader :ally, :to_sym, :where
  @count = 0
  def to_sym
    @to_sym || @to_sym = self.class.name.downcase.to_sym
  end
  def self.addcount
    @count += 1
    @count - 1
  end
  def alight(place)
    @where = place.to_sym
  end
  def hold(token)
    @hold ||= {}
    token.to_sym
    if @hold[token.to_sym]
      @hold[token.to_sym].add
    else
      @hold[token.to_sym] = token
    end
  end
  def [](token)
    @hold ||= {}
    @hold[token.to_sym]
  end
  def ally_of(pl)
    @ally = pl.to_sym
  end
  def ally?(token)
    @ally == token.ally
  end
end





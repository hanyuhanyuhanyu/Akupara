class BaseObject
  attr_reader :ally
  @count = 0
  def to_sym
    @to_sym || @to_sym = ("undefined" + BaseObject.addcount.to_s).to_sym
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
    t_sym = token.to_sym||token.class.name.downcase.to_sym
    if @hold[t_sym]
      @hold[token.to_sym].add
    else
      @hold[t_sym] = token
    end
  end
  def [](token)
    t_sym = token.to_sym||token.class.name.downcase.to_sym
    @hold&.[](t_sym) || @hold&.values&.map(&:subtype)&.flatten&.reject{|var| var.nil?}&.[](0)&.[](t_sym)
  end
  def ally_of(pl)
    @ally = pl.to_sym
  end
  def ally?(token)
    @ally == token.ally
  end
end





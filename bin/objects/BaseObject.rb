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
  def ally_of(token)
    @ally = (token.methods.include?(:allly) ? token.ally : token)
  end
  def ally?(token)
    return false if self.ally.nil? || token.ally.nil?
    self.ally == token.ally
  end
  def opponent?(token)
    return false if self.ally.nil? || token.ally.nil?
    !ally?(token)
  end
end





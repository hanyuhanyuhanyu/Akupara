class BaseObject
  @count = 0
  def to_sym
    @to_sym || @to_sym = ("undefined" + BaseObject.addcount.to_s).to_sym
  end
  def self.addcount
    @count += 1
    @count - 1
  end
  def parachute(place)
    return unless place.is_a?(Place)
    @where = place.to_sym
  end
  def hold(token)
    return unless token.is_a?(Token)
    @hold ||= {}
    if @hold[token.to_sym]
      @hold[token.to_sym].add
    else
      @hold[token.to_sym] = token
      hold(token)
    end
  end
  def [](token)
    @hold&[token.to_sym] || @hold&.values.map(&:subtype).flatten.reject{|var| var.nil?}[0][token.to_sym]
  end
end



class BaseObject
  attr_reader :where
  @count = 0
  def to_sym
    @to_sym || ("undefined" + BaseObject.addcount.to_s).to_sym
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
    @hold[token.to_sym] = token unless @hold[token.to_sym]
  end
  def [](token)
    @hold&.[](token.to_sym) || @hold&.values.map(&:subtype).flatten.reject{|var| var.nil?}[0][token.to_sym]
  end
end

Dir.glob("*").select{|fl| fl =~ /^[A-Z].*\.rb$/}.map do |fl|
  fl.gsub(/\..+$/,"")
end.each do |kls|
  next if kls == "BaseObject"
  eval "class #{kls} < BaseObject\n end"
end

Dir.glob("*").reject do |file|
  %w|BaseObject.rb sandbox.rb|.include?(file) || File::ftype(file) == "directory"
end.each do |path|
  require_relative path
end
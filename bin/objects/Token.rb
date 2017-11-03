require 'json'

class Token
  attr_reader :to_sym , :name , :subtype
  def initialize(key , value = {})
    @to_sym = key.to_sym
    @name = value["name"]
    @num = 0
    @subtype = \
      case value["subtype"] 
      when String then eval "#{value['subtype'].capitalize}.new"
      when Array 
        buf = {}
        value["subtype"].each{|sub| buf[sub.to_sym] = eval "#{sub.capitalize}.new"}
        buf
      else nil
    end
    @subtype = @subtype.subtype while @subtype.is_a?(Token)
  end
  def [](type)
    @subtype[type.to_sym] || @hold[type.to_sym]
  end
  def add(num = 1)
    @num += num
  end
  def reduce(num = 1)
    @num -= num
  end
end

TokenDef = "#{ __FILE__.split("/")[0..-2].join("/")}/def/Token.json"
JSON.parse(File.open(TokenDef,"r").read).each_pair do |key , value|
  eval <<-EOS
    class #{key.capitalize} < Token
      def initialize(key = '#{key}',value = #{value})
        super(key,value)
      end
    end
  EOS
end



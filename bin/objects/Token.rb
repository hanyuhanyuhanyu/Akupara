require 'json'

class Token
  attr_reader :name , :subtype , :amount
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
    if value["amount"].is_a?(Hash)
      (eval "#{value["subtype"].capitalize}.new.subtype.keys.map(&:to_s)").each do |key|
        value["amount"][key] = value["amount"][value["subtype"]] unless value["amount"][key]
      end
      value["amount"].delete(value["subtype"])
    end
    @amount = value["amount"]
  end
  def init
    case @amount
    when Hash 
      @amount.each_pair do |key,value|
        value.times{hold(eval "#{key.to_s.capitalize}.new")}
      end
    when Fixnum
      @num = @amount
    end
  end
  def add(num = 1)
    @num += num
  end
  def reduce(num = 1)
    @num -= num
  end
end

class TokenHolder < Hash
end
Tokens = TokenHolder.new

TokenDef = "#{ __FILE__.split("/")[0..-2].join("/")}/def/Token.json"
JSON.parse(File.open(TokenDef,"r").read).each_pair do |key , value|
  eval <<-EOS
    class #{key.capitalize} < Token
      def initialize(key = '#{key}',value = #{value} , **option)
        super(key,value)
        init if option[:init]
      end
    end
  EOS
end



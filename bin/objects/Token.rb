require 'json'

class Token
  prepend BaseMods
  attr_reader :name , :subtype , :amount
  def initialize(key , value = {})
    @to_sym = key.to_sym
    @name = value["name"]
    @num = 0
    @ally = nil
  end
  def init(amo = nil)
    case amo
    when Hash 
      amo.each_pair do |key,value|
        value.times{hold(eval "#{key.to_s.capitalize}.new")}
      end
    when Integer
      @num = amo
    end
  end
  def add(num = 1)
    @num||=0
    @num += num
  end
  def reduce(num = 1)
    @num||=0
    @num -= num
  end
end

class TokenHolder < Hash
  def setup(*token)
    token.flatten.each{|token| self[token] = eval "#{token.to_s.capitalize}.new(init:true)"}
  end
end
Tokens = TokenHolder.new

TokenDef = "#{ __FILE__.split("/")[0..-2].join("/")}/def/Token.json"
TokenJson = JSON.parse(File.open(TokenDef,"r").read)
TokenJson.each_value do |value|
  next unless value["amount"].is_a?(Hash)
  while value["amount"].keys.any?{|sub| TokenJson[sub]["subtype"]}
    value["amount"].keys.each do |sub|
      next unless TokenJson[sub]["subtype"]
      [TokenJson[sub]["subtype"]].flatten.each{|grandsub| value["amount"][grandsub] ||= value["amount"][sub]}
      value["amount"].delete sub
    end
  end
end
TokenJson.each_value do |value|
  next unless value["subtype"]
  value["subtype"] = [value["subtype"]].flatten
  value["subtype"].map!{|sub| TokenJson[sub]["subtype"] || sub}.flatten! while value["subtype"].any?{|sub| TokenJson[sub]["subtype"]}
  value["subtype"] = value["subtype"][0] if value["subtype"].length == 1
end
TokenJson.each_pair do |key , value|
  eval <<-EOS
    class #{key.capitalize} < Token
      @@subtype = #{value['subtype'] || []}
      @@amount = #{value['amount'] || 0}
      def initialize(**opt)
        super('#{key}',#{value})
        init(@@amount) if opt[:init]
      end
    end
  EOS
end



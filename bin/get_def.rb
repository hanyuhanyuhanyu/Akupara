PlaceDef = "#{File.expand_path('../def/Place.json',__FILE__)}"
PlaceJson = JSON.parse(File.open(PlaceDef,"r").read)
Places = 
if PlaceJson["default_board"]  
  setting = PlaceJson["default_board"]
  DefaultBoard.new(setting["row"],setting["col"],setting)
else
  PlaceJson.each_pair do |key,value|
    eval <<-EOS
      #{key.capitalize} = Place.new('#{key}',#{value})
      Places[:#{key.to_sym}] = #{key.capitalize}
    EOS
  end
end
Places.reconnect

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
      prepend BaseInitialize
      @@subtype = #{value['subtype'] || []}
      @@amount = #{value['amount'] || 0}
      def initialize(**opt)
        super('#{key}',#{value})
        init(@@amount) if opt[:init]
      end
    end
  EOS
end
TokenJson.each_pair do |key , value|
  eval <<-EOS
    Tokens[:#{key}] = #{key.capitalize}.new(init:true)
  EOS
end
Tokens = TokenHolder.new
SeqDef = "#{File.expand_path('../../sequence/Sequence.json',__FILE__)}"
MethodHash = JSON.parse(File.open(SeqDef,"r").read)
Sequences = Sequence.new(MethodHash)
MethodHash.each_pair do |key,value|
  next if value == ""
  def_move = "puts __method__.to_s+' is called as member of #{key}.'" 
  joiner = "\n" + (key == 'iterate' ? 'nil until ' : '')
  redef = "#{joiner} #{value.is_a?(Array) ? value.join(joiner) : value}"
  eval <<-EOS
    #{if value.is_a?(Array)
        "def " + value.join("\n #{def_move} \nend\ndef ") + "\n #{def_move} \nend"
      else
        "def #{value}\n  #{def_move} \n end"
      end
    }
    def #{key}
      #{redef}
      puts ""
    end
  EOS
end

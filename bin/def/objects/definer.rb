require "json"
class Definer
  def initialize(file)
    @file = file
  end
  def define
  end
end
class PlaceDefiner < Definer
  def define
    placejson = JSON.parse(File.open(@file,"r").read)
    ret_places = 
    if setting = placejson["default_board"]  
      DefaultBoard.new(setting["row"],setting["col"],setting)
    else
      placejson.each_pair do |key,value|
        eval <<-EOS
          #{key.capitalize} = Place.new('#{key}',#{value})
          ret_places[:#{key.to_sym}] = #{key.capitalize}
        EOS
      end
    end
    ret_places.reconnect
    ret_places
  end
end
class PlayerDefiner < Definer
end
class TokenDefiner < Definer
  def define
    token_json = JSON.parse(File.open(@file,"r").read)
    token_json.each_value do |value|
      next unless value["amount"].is_a?(Hash)
      while value["amount"].keys.any?{|sub| token_json[sub]["subtype"]}
        value["amount"].keys.each do |sub|
          next unless token_json[sub]["subtype"]
          [token_json[sub]["subtype"]].flatten.each{|grandsub| value["amount"][grandsub] ||= value["amount"][sub]}
          value["amount"].delete sub
        end
      end
    end
    token_json.each_value do |value|
      next unless value["subtype"]
      value["subtype"] = [value["subtype"]].flatten
      value["subtype"].map!{|sub| token_json[sub]["subtype"] || sub}.flatten! while value["subtype"].any?{|sub| token_json[sub]["subtype"]}
      value["subtype"] = value["subtype"][0] if value["subtype"].length == 1
    end
    token_json.each_pair do |key , value|
      eval <<-EOS
        class ::Akupara::#{key.capitalize} < ::Akupara::Token
          prepend ::Akupara::BaseInitialize
          @@subtype = #{value['subtype'] || []}
          @@amount = #{value['amount'] || 0}
          def initialize(**opt)
            super('#{key}',#{value})
            init(@@amount) if opt[:init]
          end
        end
      EOS
    end
    tokens = TokenHolder.new
    token_json.each_pair do |key , value|
      eval <<-EOS
        tokens[:#{key}] = #{key.capitalize}.new(init:true)
      EOS
    end
    tokens
  end
end


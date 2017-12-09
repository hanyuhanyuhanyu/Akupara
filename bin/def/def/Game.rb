require "json"
class Definer
  def initialize(file)
    @file = file
  end
  def define
  end
end
class PlaceDefiner < Definer
  def initialize(file)
    placejson = JSON.parse(File.open(file,"r").read)
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
  def initialize(file) 
  end 
end
class TokenDefiner < Definer
end
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
S
module Akupara
  class Game
    def self.set_def_files(**files)
      @@places = PlaceDefiner.new files[:place]
      @@players = PlayerDefiner.new files[:player]
      @@Tokens = TokenDefiner.new files[:token]
    end
  end
end

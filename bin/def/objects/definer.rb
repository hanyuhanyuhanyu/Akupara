module Akupara
  require "json"
  class Definer
    def initialize(json = {})
      @json = json
    end
    def define
    end
  end
  class PlaceDefiner < Definer
    def define
      return PlaceHolder.new unless @json
      ret_places = PlaceHolder.new
      if setting = @json["default_board"]  
        ret_places = DefaultBoard.new(setting["row"],setting["col"],setting)
      else
        @json.each_pair do |key,value|
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
    def define
      return PlayerHolder.new unless @json
      PlayerHolder.new
    end
  end
  class TokenDefiner < Definer
    def define
      return TokenHolder.new unless @json
      @json.each_value do |value|
        next unless value["amount"].is_a?(Hash)
        while value["amount"].keys.any?{|sub| @json[sub]["subtype"]}
          value["amount"].keys.each do |sub|
            next unless @json[sub]["subtype"]
            [@json[sub]["subtype"]].flatten.each{|grandsub| value["amount"][grandsub] ||= value["amount"][sub]}
            value["amount"].delete sub
          end
        end
      end
      @json.each_value do |value|
        next unless value["subtype"]
        value["subtype"] = [value["subtype"]].flatten
        value["subtype"].map!{|sub| @json[sub]["subtype"] || sub}.flatten! while value["subtype"].any?{|sub| @json[sub]["subtype"]}
        value["subtype"] = value["subtype"][0] if value["subtype"].length == 1
      end
      @json.each_pair do |key , value|
        eval <<-EOS
          class ::Akupara::#{key.capitalize} < ::Akupara::Token
            prepend ::Akupara::BaseInitialize
            @@subtype = #{value['subtype'] || []}
            @@amount = #{value['amount'] || 0}
            @@movable = []
            @@movable = Moveables.new(#{value['movable']}) if #{value['movable']}
            p @@movable
            def initialize(**opt)
              super('#{key}',#{value})
              init(@@amount) if opt[:init]
            end
          end
        EOS
      end
      tokens = TokenHolder.new
      @json.each_pair do |key , value|
        eval <<-EOS
          tokens[:#{key}] = #{key.capitalize}.new(init:true)
        EOS
      end
      tokens
    end
  end
end


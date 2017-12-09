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

def_hash = {}.tap{|hash|Dir.glob(File.expand_path("../.def/",__FILE__)).each do |file|
    hash[file.split("/")[-1].lowercase.gsub(".json","").to_sym] = file
  end
  p hash
}
p def_hash
::Akupara::Game.set_definition def_hash

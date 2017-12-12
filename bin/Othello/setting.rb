def_hash = {}.tap{|hash|Dir.glob(File.expand_path("../def/*.json",__FILE__)).each do |file|
    hash[file.split("/")[-1].downcase.gsub(".json","").to_sym] = file
  end
  break hash
}
::Akupara::Game.set_definition def_hash
require_relative File.expand_path("../Othello_main.rb",__FILE__)

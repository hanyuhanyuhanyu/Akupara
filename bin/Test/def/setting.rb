def_hash = {}.tap{|hash|Dir.glob(File.expand_path("../*.json",__FILE__)).each do |file|
    hash[file.split("/")[-1].downcase.gsub(".json","").to_sym] = file
  end
}
::Akupara::Game.set_definition def_hash
module Akupara
  class Game 
    def init
      hoge =  @@places.values.map(&:to_sym)
      p hoge
    end
  end
end

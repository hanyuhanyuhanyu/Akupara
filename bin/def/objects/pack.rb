here_path = File.expand_path("../",__FILE__)
require here_path+"/BaseObject.rb"
Dir.glob(File.expand_path("../*.rb",__FILE__)).select{|f| f !~ /BaseObject.rb/ && f=~/[A-Z]/}.each{|f| require f}
require here_path+"/Game.rb"

here_path = File.expand_path("../",__FILE__)
require here_path+"/baseobject.rb"
Dir.glob(File.expand_path("../*.rb",__FILE__)).select{|f| f=~/^[A-Z]/}.each{|f| require f}
require here_path+"/definer.rb"

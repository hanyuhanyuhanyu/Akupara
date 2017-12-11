here_path = File.expand_path("../",__FILE__)
require here_path+"/baseobject.rb"
Dir.glob(here_path+"/*.rb").select{|f| f=~/[A-Z][^\/]*\.rb/}.each{|f| require f}
require here_path+"/definer.rb"

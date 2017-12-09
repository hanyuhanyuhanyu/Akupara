require File.expand_path("../BaseObject.rb",__FILE__)

Dir.glob(File.expand_path("../*.rb",__FILE__)).select{|f| f !~ /BaseObject.rb/ && f=~/[A-Z]/}.each{|f| require f}

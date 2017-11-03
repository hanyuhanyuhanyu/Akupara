dir = __FILE__.split("/")[0..-2].join("/")
require "#{dir}/BaseObject.rb"
files = Dir.glob(dir + "/*").select{|fl| fl.split("/")[-1] =~ /^[A-Z].*\.rb$/ && fl.split("/")[-1] != "BaseObject.rb"}

files.map do |fl|
  fl.split("/")[-1].gsub(/\..+$/,"")
end.each do |kls|
  eval "class #{kls} < BaseObject\n end"
end

files.reject do |file|
  File::ftype(file) == "directory"
end.each do |path|
  require path
end
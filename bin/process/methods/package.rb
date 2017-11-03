Dir.glob("process/methods/*").select{|fl| fl =~ /\.rb$/}.reject{|fl| fl.split("/")[-1] == "package.rb"}.each do |fl|
  require_relative Dir.pwd + "/" + fl
end
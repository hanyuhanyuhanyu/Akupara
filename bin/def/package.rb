dir = __FILE__.split("/")[0..-2].join("/") 
require "#{dir}/Default.rb"
Dir.glob("#{dir}/*").select{|fl| fl =~ /\.rb$/}.reject{|fl| ["package.rb","Default.rb"].include?(fl.split("/")[-1])}.each do |fl|
  require fl
end
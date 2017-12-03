exit if ARGV.empty?
game = ARGV.join("/")
dir = Dir.glob("./#{game}")[0]
dir.split("/").<<("").inject do |path,sub| 
  setter = "#{path}/def/setting.rb"
  require_relative setter if File.exist?(setter)
  path += "/".+(sub)
end
require_relative "objects/package.rb"
require_relative "process/sequence.rb"
Sequences.run



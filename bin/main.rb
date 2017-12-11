(warn "No ARGV Exception."; exit)if ARGV.empty?

game = ARGV.join("/")
dir = Dir.glob("./#{game}")[0]

(warn "#{game} not found." ; exit ) if dir.nil?

dir.split("/").<<("").inject do |path,sub| 
  setter = "#{path}/def/setting.rb"
  require_relative setter if File.exist?(setter)
  path += "/".+(sub)
end
Akupara::Game.new.run



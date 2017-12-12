(warn "No ARGV Exception."; exit)if ARGV.empty?
game = ARGV.join("/")
dir = Dir.glob("./#{game}")[0]

(warn "#{game} not found." ; exit ) if dir.nil?

dir.split("/").<<("").inject do |path,sub| 
  setter = "#{path}/setting.rb"
  require_relative setter if File.exist?(setter)
  def_file = path + "/def"
  while Dir.exist?(def_file)
    ("#{def_file}/setting.rb").tap{|pt| break unless File.exist?(pt); require_relative pt}
    def_file += "/def"
  end
  path += "/".+(sub)
end
Akupara::Game.new.run



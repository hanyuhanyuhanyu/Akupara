require "json"
require_relative "../objects/package.rb"
require_relative "methods/package.rb"

def init
  puts "------Method 'init' called------"
  puts "When you run main.rb, Akupara call the method 'init' first."
  puts "You can redefine this by edit 'sequence.rb' and do same thing to 'iterate', 'close' method, which will be called later."
  puts ""
end

def iterate
  puts "------Method 'iterate' called------"
  puts "After calling 'init', Akupara call the 'iterate' method, which is supposed to define bourd game's playing part!"
  puts "It stands for playing parts which iterate many times."
  puts "The 'iterate' method can have some methods inside. Those methods indicate 'Phases' of the game."
  puts ""
end

def close
  puts "------Method 'close' called------"
  puts "When the game finish, Akupara call the 'close' method."
  puts "This method is supposed to do calculate score, decide the winner or some else."
  puts ""
end

SeqDef = __FILE__.split("/")[0..-2].join("/") + "/sequence/Sequence.json"
JSON.parse(File.open(SeqDef,"r").read).each_pair do |key,value|
  next if value == ""
  def_move = "puts __method__.to_s+' is called as iterator.'" 
  eval <<-EOS
    #{if value.is_a?(Array)
        "def " + value.join("\n #{def_move} \nend\ndef ") + "\n #{def_move} \nend"
      else
        "def #{value}\n  #{def_move} \n end"
      end
    }
    def #{key}
      #{value.is_a?(Array) ? value.join("\n") : value}
      puts ""
    end
  EOS
end





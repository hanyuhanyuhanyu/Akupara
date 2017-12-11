module Akupara
  require 'json'
  class Game 
   def self.set_def_files(**files)
     @@places = PlaceDefiner.new(files[:place]).define
     @@players = PlayerDefiner.new(files[:player]).define
     @@tokens = TokenDefiner.new(files[:token]).define
     @@sequences = SequenceDefiner.new(files[:sequence]).define
   end
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
  end
  class SequenceDefiner < Definer
    def initialize(file)
      JSON.parse file 
    end
  end
  class Sequence
    def initialize(method_hash)
      @methods = method_hash.values.flatten.map(&:to_sym)
      @each_divs = {}
      method_hash.each_pair do |key,value|
        @each_divs[key.to_sym] = value.is_a?(Array) ? value[0].to_sym : value.to_sym
      end
    end
    def run(met = @methods[0])
      game = Game.new
      while met
        met = @each_divs[met] if @each_divs[met]
        buf = game.send(met)
        met = if @methods.include?(buf)
          buf
        elsif @each_divs[buf]
          @each_divs[buf]
        else
          buf = @methods[@methods.index(met) + 1]
          @each_divs[:close] == buf ? @each_divs[:iterate] : @methods[@methods.index(met) + 1]
        end
      end
    end
  end 
end
SeqDef = "#{File.expand_path('../../sequence/Sequence.json',__FILE__)}"
MethodHash = JSON.parse(File.open(SeqDef,"r").read)
Sequences = Sequence.new(MethodHash)
MethodHash.each_pair do |key,value|
  next if value == ""
  def_move = "puts __method__.to_s+' is called as member of #{key}.'" 
  joiner = "\n" + (key == 'iterate' ? 'nil until ' : '')
  redef = "#{joiner} #{value.is_a?(Array) ? value.join(joiner) : value}"
  Game.class_eval do 
    eval <<-EOS
      #{if value.is_a?(Array)
          "def " + value.join("\n #{def_move} \nend\ndef ") + "\n #{def_move} \nend"
        else
          "def #{value}\n  #{def_move} \n end"
        end
      }
      def #{key}
        #{redef}
        puts ""
      end
    EOS
  end
end

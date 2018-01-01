module Akupara
  class Game 
    def self.set_definition(**files)
      @placefile ||= {} 
      @playerfile ||= {} 
      @tokenfile ||= {}
      @sequencefile ||= {} 
      @placefile.merge!(JSON.parse(File.open(files[:place],"r").read)) if files[:place]
      @playerfile.merge!(JSON.parse(File.open(files[:player],"r").read)) if files[:player] 
      @tokenfile.merge!(JSON.parse(File.open(files[:token],"r").read)) if files[:token] 
      @sequencefile.merge!(JSON.parse(File.open(files[:sequence],"r").read)) if files[:sequence] 
      @@places = PlaceDefiner.new(@placefile).define
      @@players = PlayerDefiner.new(@playerfile).define
      @@tokens = TokenDefiner.new(@tokenfile).define
      @@sequences = SequenceDefiner.new(@sequencefile).define if files[:sequence] 
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
      :close
    end

    def close
      puts "------Method 'close' called------"
      puts "When the game finish, Akupara call the 'close' method."
      puts "This method is supposed to do calculate score, decide the winner or some else."
      puts ""
    end
  
    def run(met = nil)
      #when this file is loaded,@@sequences is supposed not to be defined. 
      #so it cannot set as default value directly.
      met ||= @@sequences.methods[0]
      while met
        met = @@sequences.each_divs[met] || met
        buf = self.send(met)
        met = if @@sequences.methods.include?(buf)
          buf
        elsif @@sequences.each_divs[buf]
          @@sequences.each_divs[buf]
        else
          buf = @@sequences.methods[@@sequences.methods.index(met) + 1]
          @@sequences.each_divs[:close] == buf ? @@sequences.each_divs[:iterate] : @@sequences.methods[@@sequences.methods.index(met) + 1]
        end
      end
    end
    def playing 
      @@players.playing
    end
  end
  class ::Akupara::SequenceDefiner < ::Akupara::Definer
    def define
      return Sequence.new unless @json
      ret_sequences = Sequence.new(@json)
      @json.each_pair do |key,value|
        next if value == ""
        def_move = "puts __method__.to_s+' is called as member of #{key}.'" 
        joiner = "\n" + (key == 'iterate' ? 'nil until ' : '')
        redef = "#{joiner} #{value.is_a?(Array) ? value.join(joiner) : value}"
        ::Akupara::Game.class_eval do 
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
      ret_sequences
    end
  end
  class Sequence
    attr_reader :each_divs , :methods
    def initialize(method_hash = {"init":"init","iterate":"iterate","close":"close"})
      @methods = method_hash.values.flatten.map(&:to_sym)
      @each_divs = {}
      method_hash.each_pair do |key,value|
        @each_divs[key.to_sym] = value.is_a?(Array) ? value[0].to_sym : value.to_sym
      end
    end
  end 
end


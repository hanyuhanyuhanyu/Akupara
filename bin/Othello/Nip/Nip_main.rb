module Akupara
  class Place
    def gather(direction , &block)
      if @direction[direction]
        target = @direction[direction]
      else
        return [] if @direction.values.count != 4  
        next_dir = [:up,:down].include?(direction) ? ["right_","left_"].map{|d| d.+(direction.to_s).to_sym} : ["_up","_down"].map{|d| direction.to_s.+(d).to_sym}
        direction = next_dir.select{|d| @direction[d]}.first
        target = next_dir.map{|d| @direciont[d]}.reject(&:nil?).first
        return [] unless target  
      end
      block = ->(_){true} unless block_given?
      (block.call(target) ? [target] : []) + target.gather(direction,&block)
    end
  end
  class Game
    def show_the_board
      rows = ["   "] * 2
      0.upto(7){|n| rows[0] += "c ";rows[1] += "#{n} "}
      rows = [rows.join("\n")+("\n")]
      0.upto(7) do |row|
        rows << "r#{row}|" + [*0...8].map{|col| p @@places["r#{row}c#{col}".to_sym]&.to_sym;@@places["r#{row}c#{col}".to_sym]}.map{|item| item.nil? ? "X" : item.show}.join("|") + ("|\n")
      end
      row_line = "  " + "-"*(8*2+1) + "\n"
      puts rows.join(row_line) + row_line
    end
  end
end

module Akupara
  class Place
    def gather(direction , &block)
      if @direction[direction]
        target = @direction[direction]
      else
        return [] if block_given? && !block.call(self) 
        return [] if @direction.values.count != 4
        next_dir = direction.to_s.include?("_") ? direction.to_s.split("_").map(&:to_sym) : nil
        next_dir ||= [:up,:down].include?(direction) ? ["right_","left_"].map{|d| d.+(direction.to_s).to_sym} : ["_up","_down"].map{|d| direction.to_s.+(d).to_sym}
        target = next_dir.map{|d| @direction[d]}.reject(&:nil?).first
        return [] unless target  
        direction = next_dir.select{|d| @direction[d]}.first
        unless block_given?
          puts ["def_block",self.to_sym]
          block = ->(target){target.to_sym != self.to_sym.clone}
        end
      end
      (!block_given? || block.call(target) ? [target] : []) + target.gather(direction,&block)
    end
  end
  class Game
    def show_the_board
      rows = ["   "] * 2
      0.upto(7){|n| rows[0] += "c ";rows[1] += "#{n} "}
      rows = [rows.join("\n")+("\n")]
      0.upto(7) do |row|
        rows << "r#{row}|" + [*0...8].map{|col|@@places["r#{row}c#{col}".to_sym]}.map{|item| item.nil? ? "X" : item.show}.join("|") + ("|\n")
      end
      row_line = "  " + "-"*(8*2+1) + "\n"
      puts rows.join(row_line) + row_line
    end
  end
end

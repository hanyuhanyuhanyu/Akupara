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
end

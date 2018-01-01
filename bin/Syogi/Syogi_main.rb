module Akupara
  class Game
    def set_player
      2.times do @players.add_player end
    end
    def set_token
      top = []; top << Fu
      middle = Array.new(9); middle[1] = Kaku;middle[7] = Hisha
      bottom_parts = [Kin,Gin,Keima,Kyosha]
      bottom = bottom_parts.reverse + [Ou] + bottom_parts
      9.times do |col|
        top[col].new.alight @places[6,col]
        middle[col].new.alight @places[7,col]
        bottom[col].new.alight @places[8,col] 
        top[col].new.alight @places[2,8-col]
        middle[col].new.alight @places[7,8-col]
        bottom[col].new.alight @places[8,8-col] 
      end
    end

    def require_input
    end
    def move
    end
    def reverse?
    end
    def checkmated?
      :close
    end

    def praise_winner
    end
  end
end


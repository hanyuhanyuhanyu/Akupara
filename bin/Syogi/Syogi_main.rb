module Akupara
  class Game
    def set_player
      2.times do @players.add_player end
    end
    def set_token
      pawns = []
      9.times{pawns << Fu.new}
      2.times{pawns << [Kin.new,Gin.new,Keima.new,Kyosha.new]}
      pawns << [Hisha.new,Kaku.new,Ou.new]
      pawns.flatten!
    p @players.values.map(&:name)
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



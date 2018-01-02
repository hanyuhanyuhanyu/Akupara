module Akupara
  class Player
    def set_king(king)
      @king = king
    end
    def king
      @king
    end
    def my_pawns(pawn)
      @pawns ||= []
      @pawns << pawn
    end
    def pawns
      @pawns
    end
    def hold_pawns
      @hold
    end
  end
  class Token
    def reverse
      return self if reversed?
      ret = Narikin.new
      ret.origin(self.class)
      return Narikin.new
    end
    def reversed?
      false
    end
  end
  class Ou
    def reversed?
      true
    end
  end
  class Hisha
    def reverse
      return Ryuou.new
    end
  end
  class Kaku
    def reverse
      return Ryoma.new
    end
  end
  class Ryuou
    def reverse
      return Hisha.new
    end
    def reversed?
      true
    end
  end
  class Ryoma
    def reverse
      return Kaku.new
    end
    def reversed?
      true
    end
  end
  class Narikin
    def origin(pawn)
      @origin = pawn
    end
    def reverse
      return @origin&.new || Fu.new
    end
    def reversed?
      true
    end
  end
  class Game
    def init
      @pawn = nil
      @moving = nil
    end
    def set_player
      2.times do @players.add_player end
    end
    def set_token
      top = Array.new(9,Fu)
      middle = Array.new(9); middle[1] = Kaku;middle[7] = Hisha
      bottom_parts = [Kin,Gin,Keima,Kyosha]
      bottom = bottom_parts.reverse + [Ou] + bottom_parts
      9.times do |col|
        top[col].new.alight @places[6,col]
        middle[col].new.alight @places[7,col] if middle[col]
        bottom[col].new.alight @places[8,col] 
        @players.next
        3.times{|row|
          pawn = @places[row+6,col].placing
          next unless pawn
          pawn.ally_of(playing.to_sym)
          playing.my_pawns pawn
        }
        playing.ally_of(playing.to_sym)
        top[col].new.alight @places[2,8-col]
        middle[col].new.alight @places[1,8-col] if middle[col]
        bottom[col].new.alight @places[0,8-col] 
        @players.next
        3.times{|row|
          pawn = @places[row,8-col].placing
          next unless pawn
          pawn.ally_of(playing.to_sym)
          playing.my_pawns pawn
        }
        3.times{|row| @places[row+6,col].placing&.clockwise(4)}
        playing.ally_of(playing.to_sym)
      end
      @players.next
      playing.set_king @places[8,4].placing
      @players.next
      playing.set_king @places[0,4].placing
    end

    def show
      strs = @places.values.map{|plc| plc.placed? ? plc.placing.name : "  "}
      puts "-"*(2*9+8+2)
      9.times{|raw|
        puts "|" + strs[raw*9...raw*9+9].join("|") + "|"
        puts "-"*(2*9+8+2)
      }
    end
    def require_input
      input = STDIN.gets
      case input
      when "hand"
        hand
      else 
        place = @places[input[0].to_i,input[1].to_i]
        if !place || !place.placing&.ally?(playing)
          puts "you cannot select from that grid!"
          return :show 
        end
        @pawn = place.placing
        return try_move
      end
    end
    def move
      unless @placing.placing.nil?
        playing.hold @placing.placing
        @placing.placing.leave
      end
      @pawn.alight @placing
    end
    def reverse?
      return unless [6,7,8].map{|i| i + playing.to_sym.to_s[-1].to_i * (-6)}.include?(@placing.row.to_i)
      puts "promote the pawn? (y/n)"
      input = ""
      until input.match(/[ynYN]/)
        case input
        when /[yY]/
          @pawn.leave
          @pawn = @pawn.reverse
          @pawn.alight @placing
        end
      end
    end
    def checkmated?
      #ou no basyo to ou no mawari no doreka ni daremo toutatu dekinai nara sippai
      all_reachable = {}
      must_reachable = {}
      @players.each_pair{|key,val|
        all_reachable[key] = val.pawns.map{|p| p.list_reachables.map(&:to_sym)}.flatten.uniq.sort
        must_reachable[key] = ([val.king.where] + DefaultBoard.all_dir.map{|dir| val.king.where.send dir}).reject(&:nil?).map(&:to_sym)
      }
      checkable = all_reachable.values.map.with_index{|val,ind|
        must_reachable.values[ind-1].all?{|p| val.include? p}
      }
      checkable.map.with_index{|val,ind|
        next false unless val
        me,opp = *@players.values[ind..(ind+1)%(@players.values.length)]
        killables = me.pawns.select{|p| p.list_reachables.include? opp.king.where}
      #ou no masu ni toutatu kanou na koma ga hutatu izyou nara tumi
        next true if killables.size > 1
        next false if killables.size < 1
      #sou de nai nara, oute wo kaketeiru koma wo koroseru nara tunde nai
        killing = killables.first
        followers = opp.pawns.reject{|p| p === Ou}
        next false unless followers.select{|p| p.list_reachables.include? killing.where}.empty?
      #oute wo kaketeru koma ga rinsetu siteiru koma nara tumi 
        next true if ([opp.king.where] + DefaultBoard.all_dir.map{|dir| opp.king.where.send dir}).include?(killing.where)
      #tegoma ga areba tunde nai 
        next false if opp.hold_pawns.length > 0 
      #oute wo kaketeru koma no keiro no dokonimo toutatu dekinai nara tumi 
        next  followers.select{|p| killing.route(opp.king.where).any?{|r| p.list_reachables.include? r}}.empty?
      }
    end

    def praise_winner
    end

    def hand
    end
    def try_move
      input = STDIN.gets
      case input
      when "quit"
        return :show
      else
        place = @places[input[0].to_i,input[1].to_i]
        if !place || place.placing
          puts "you cannot place the pawn on that place!"
          return :show
        end
        unless @pawn.list_reachables.include?(place)
          puts "that pawn cannot move to that place!"
          return :show
        end
        @placing = place
        return :move
      end
    end

  end
end


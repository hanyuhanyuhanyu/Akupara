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
      pawn.ally_of(self.to_sym)
    end
    def fire_pawn(pawn)
      @pawns.reject{|p| p.eql? pawn}
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
      ret.ally_of(self.ally)
      ret
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
      ret = Ryuou.new
      ret.ally_of(self.ally)
      return ret
    end
  end
  class Kaku
    def reverse
      ret = Ryoma.new
      ret.ally_of(self.ally)
      return ret
    end
  end
  class Ryuou
    def reverse
      ret = Hisha.new
      ret.ally_of(self.ally)
      return ret
    end
    def reversed?
      true
    end
  end
  class Ryoma
    def reverse
      ret = Kaku.new
      ret.ally_of(self.ally)
      return ret
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
      ret = @origin&.new || Fu.new
      ret.ally_of(self.ally)
      return ret
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
      strs = @places.values.map{|plc|
        color = plc.placing&.ally?(@players.values.first) ? "\e[31m" : "\e[0m"
        "#{color}#{plc.placed? ? plc.placing.name : "  "}\e[0m"
      }
      puts "-"*(2*9+8+2)
      9.times{|raw|
        puts "|" + strs[raw*9...raw*9+9].join("|") + "|"
        puts "-"*(2*9+8+2)
      }
      @players.values.each{|val|
        print "#{val.to_sym.to_s}'s hand:"
        puts val.hold_pawns.map{|key,val| "#{val.name} => #{val.num}"}.join(",")
      }
    end
    def require_input
      @pawn = nil
      @placing = nil
      input = STDIN.gets.chomp
      case input
      when "hand"
        return hand
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
      pawn = @placing.placing
      unless pawn.nil?
        take = pawn.reversed? ? pawn.reverse : pawn
        @players.next
        playing.fire_pawn pawn
        @players.next
        playing.hold take
        pawn.leave
      end
      @pawn.alight @placing
    end
    def reverse?
      return unless [6,7,8].map{|i| i + playing.to_sym.to_s[-1].to_i * (-6)}.include?(@placing.row.to_i)
      puts "promote the pawn? (y/n)"
      input = ""
      until input.match(/[ynYN]/)
        input = STDIN.gets
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
      checked = checkable.map.with_index{|val,ind|
        next nil unless val
        me,opp = *@players.values[ind..(ind+1)%(@players.values.length)]
        killables = me.pawns.select{|p| p.list_reachables.include? opp.king.where}
      #ou no masu ni toutatu kanou na koma ga hutatu izyou nara tumi
        next opp if killables.size > 1
        next nil if killables.size < 1
      #sou de nai nara, oute wo kaketeiru koma wo koroseru nara tunde nai
        killing = killables.first
        followers = opp.pawns.reject{|p| p === Ou}
        next nil unless followers.select{|p| p.list_reachables.include? killing.where}.empty?
      #oute wo kaketeru koma ga rinsetu siteiru koma nara tumi 
        next opp if ([opp.king.where] + DefaultBoard.all_dir.map{|dir| opp.king.where.send dir}).include?(killing.where)
      #tegoma ga areba tunde nai 
        next nil if opp.hold_pawns.length > 0 
      #oute wo kaketeru koma no keiro no dokonimo toutatu dekinai nara tumi 
        next opp if followers.select{|p| killing.route(opp.king.where).any?{|r| p.list_reachables.include? r}}.empty?
        nil
      }.reject(&:nil?)
      unless checked.empty?
        @checked = checked.first
        return :praise_winner
      end
      @players.next
    end

    def praise_winner
      @checked
    end

    def hand
      holding = playing.hold_pawns.values
      if holding.empty?
        puts "you have no pawns in your hand!"
        return :show
      end
      holding.each_with_index{|val,ind|
        puts "[#{ind}]#{val.name} (having #{val.num})"
      }
      puts "which one?"
      input = STDIN.gets.to_i
      case input
      when 0...holding.length
        puts "where?"
        @pawn = holding[input].class.new
        return try_place 
      else
        puts "invalid input!"
        return hand
      end
    end
    def try_move
      input = STDIN.gets.chomp
      case input
      when "quit"
        return :show
      else
        place = @places[input[0].to_i,input[1].to_i]
        if !place || place.placing&.ally?(playing)
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
    def try_place
      input = STDIN.gets.chomp
      place = @places[input[0].to_i,input[1].to_i]
      if !place || place.placing
        puts "you cannot place your pawn on that place from your hand!"
        return :show
      end
      playing.release @pawn.to_sym
      playing.my_pawns @pawn
      @placing = place
      move
      return :checkmated?
    end
  end
end


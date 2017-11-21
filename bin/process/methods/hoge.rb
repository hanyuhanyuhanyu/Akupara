def token_load
  puts "this method will distribute enomerous number of token on you board."
  Tokens.setup(:disease,:cure,:base)
#  p Tokens
#  p Tokens[:disease]
  p Tokens
end
def confirm_role
  puts "this method will distribute roles to every player."
end

def play
  :close
end

def calculate
  puts "this do nothing!"
end
def finish
  puts "end of line..."
end

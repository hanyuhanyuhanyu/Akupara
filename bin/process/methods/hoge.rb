def token_load
  puts "this method will distribute enomerous number of token on you board."
  Tokens[:disease] = Disease.new(init:true)
  Tokens[:cure] = Cure.new(init:true)
  Tokens[:base] = Base.new(init:true)
#  p Tokens
#  p Tokens[:disease]
  p Tokens[:base]
end
def confirm_role
  puts "this method will distribute roles to every player."
end

def play
  true
end

def calculate
  puts "this do nothing!"
end
def finish
  puts "end of line..."
end

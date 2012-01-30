# WEBrick compatible for Ruby1.9
class String
  alias_method :each, :lines
end

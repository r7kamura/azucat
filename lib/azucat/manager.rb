module Azucat
  module Manager
    extend self
    def run
      # Please override this for utility
      # For example:
      # Azucat::Manager.send(:define_method, :run, proc { Azucat.stop })
    end
  end
end

module Azucat
  module Notify
    extend self

    def notify(args)
      if match_any_filter?(args[:filtered])
        ::Notify.notify args[:title], args[:message]
      end
    end

    def register(regexp)
      filters << regexp unless filters.include?(regexp)
    end

    def unregister(regexp)
      filters.delete(regexp)
    end

    private

    def filters
      @filters ||= []
    end

    def match_any_filter?(str)
      filters.any? &str.method(:match)
    end
  end
end

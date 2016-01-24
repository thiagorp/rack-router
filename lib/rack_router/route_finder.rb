module RackRouter
  class RouteFinder
    attr_reader :routes

    def initialize(args)
      @routes = args[:routes]
    end

    def route_for(request)
      routes.detect { |route| route.matches_request?(request) }
    end
  end
end

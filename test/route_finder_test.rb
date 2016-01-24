require 'test_helper'
require 'rack_router/route_finder'
require 'roles/route_matcher'

class MatchesRequestDouble
  def matches_request?(request)
    true
  end
end

class NotMatchesRequestDouble
  def matches_request?(request)
    false
  end
end

class TestRouteFinder < MiniTest::Unit::TestCase
  def test_it_returns_the_first_matched_route
    route_1 = NotMatchesRequestDouble.new
    route_2 = MatchesRequestDouble.new
    route_3 = MatchesRequestDouble.new

    matched = 
      RackRouter::RouteFinder
        .new(routes: [route_1, route_2, route_3])
        .route_for(request)

    assert_equal matched, route_2
  end

  def test_it_returns_nil_if_none_found
    route_1 = NotMatchesRequestDouble.new

    matched =
      RackRouter::RouteFinder
        .new(routes: [route_1])
        .route_for(request)

    assert_equal matched, nil
  end

  private

  def request
    {}
  end
end

class TestMatchesRequestDouble < MiniTest::Unit::TestCase
  include RouteMatcherTest

  def setup
    @sut = MatchesRequestDouble.new
  end
end

class TestNotMatchesRequestDouble < MiniTest::Unit::TestCase
  include RouteMatcherTest

  def setup
    @sut = NotMatchesRequestDouble.new
  end
end


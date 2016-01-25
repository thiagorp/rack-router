require 'test_helper'
require 'roles/route_matcher'
require 'rack_router/route'

class RequestDouble
  def initialize(args = {})
    @method = args[:method]
    @path = args[:path]
  end

  def method
    @method ||= :get
  end

  def path
    @path ||= '/test/path'
  end
end

class TestRoute < MiniTest::Test
  include RouteMatcherTest

  def setup
    @sut = Route.new(
      method: :get,
      path: '/test/path'
    )
  end

  def test_it_matches_with_exact_path
    request = RequestDouble.new(
      method: :get,
      path: '/test/path'
    )
    route = Route.new(
      method: :get,
      path: '/test/path'
    )

    matches = route.matches_request?(request)

    assert matches
  end

  def test_it_matches_with_exact_path_and_trailing_slash
    request = RequestDouble.new(
      method: :get,
      path: '/test/path/'
    )
    route = Route.new(
      method: :get,
      path: '/test/path'
    )

    matches = route.matches_request?(request)

    assert matches
  end

  def test_it_matches_a_route_with_params
    request = RequestDouble.new(
      method: :get,
      path: '/test/path'
    )
    route = Route.new(
      method: :get,
      path: '/test/:param'
    )

    matches = route.matches_request?(request)
    
    assert matches
  end

  def test_it_matches_a_route_with_trailing_slash
    request = RequestDouble.new(
      method: :get,
      path: '/test/path/'
    )
    route = Route.new(
      method: :get,
      path: '/test/:param'
    )

    matches = route.matches_request?(request)
    
    assert matches
  end

  def test_it_doesnt_match_a_path_with_extra_trailing_segments
    request = RequestDouble.new(
      method: :get,
      path: '/test/path/extra'
    )
    route = Route.new(
      method: :get,
      path: '/test/:param'
    )

    matches = route.matches_request?(request)
    
    refute matches
  end

  def test_it_doesnt_match_a_path_with_extra_leading_segments
    request = RequestDouble.new(
      method: :get,
      path: '/leading/test/path'
    )
    route = Route.new(
      method: :get,
      path: '/test/:param'
    )

    matches = route.matches_request?(request)
    
    refute matches
  end

  def test_it_doesnt_match_a_path_with_different_method
    request = RequestDouble.new(
      method: :get,
      path: '/test/path'
    )
    route = Route.new(
      method: :post,
      path: '/test/path'
    )

    matches = route.matches_request?(request)
    
    refute matches
  end
end

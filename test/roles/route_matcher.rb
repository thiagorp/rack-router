module RouteMatcherTest
  def test_it_matches_a_route
    assert_respond_to @sut, :matches_request?
  end
end

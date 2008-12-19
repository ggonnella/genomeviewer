require 'test_helper'

class StyleControllerTest < ActionController::TestCase

  fixtures 'users'

  def setup
    @u = users('a_test')
    # session:
    @in = {:user => @u.id}
    @out = {}
  end

  def test_unlogged_access_refused
    get :index, {}, @out
    assert_redirected_to root_url
  end

  def test_logged_in_access
    get :index, {}, @in
    assert_template "style/index"
  end

end

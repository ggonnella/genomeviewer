require 'test_helper'

class ViewerControllerTest < ActionController::TestCase

  def setup
    user_setup # see test_helper
  end

  def test_username_from_params
    get :index, :username => unknown_username
    assert flash[:errors] =~ /user/i
    get :index, {:username => @_u.username}
    assert flash[:errors] !~ /user/i
  end
  
  def test_annotation_from_params
    get :index, {:username => @_u.username,
                 :annotation => @_a.name}, 
                {:user => @_u.id}
    assert_equal @_a, assigns(:annotation) 
  end
  
  def test_private_annotation_not_own
    get :index, {:username => @_u.username,
                 :annotation => @_a.name}
    assert flash[:errors] =~ /private/i
  end
  
  def test_sequence_region_from_params_implicit
    get :index, {:username => @_u.username,
                 :annotation => @_a.name}, 
                {:user => @_u.id}
    assert_equal @_sr, assigns(:sequence_region) 
  end
    
  def test_sequence_region_from_params_explicit
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :seq_region => @_sr.seq_id}, 
                {:user => @_u.id}
    assert_equal @_sr, assigns(:sequence_region) 
  end
    
  def test_sequence_region_from_params_error
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :seq_region => "foobar"}, 
                {:user => @_u.id}
    assert flash[:errors] =~ /sequence region/i
  end
  
  def test_viewport_start_from_params_implicit
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :seq_region => @_sr.seq_id}, 
                {:user => @_u.id}
    assert_equal 1000, assigns(:start)
  end
  
  def test_viewport_start_from_params_explicit
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :seq_region => @_sr.seq_id,
                 :start_pos => 2000}, 
                {:user => @_u.id}
    assert_equal 2000, assigns(:start)
  end
  
  def test_viewport_start_from_params_too_low
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :seq_region => @_sr.seq_id, 
                 :start_pos => 500}, 
                {:user => @_u.id}
    assert_equal 1000, assigns(:start)
  end
  
  def test_viewport_start_from_params_too_high
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :seq_region => @_sr.seq_id, 
                 :start_pos => 10000}, 
                {:user => @_u.id}
    assert_equal 8999, assigns(:start)
  end
  
  def test_viewport_end_from_params_implicit
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :seq_region => @_sr.seq_id,
                 :start_pos => 2000}, 
                {:user => @_u.id}
    assert_equal 9000, assigns(:end)
  end
  
  def test_viewport_end_from_params_explicit
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :seq_region => @_sr.seq_id,
                 :start_pos => 2000,
                 :end_pos => 3000}, 
                {:user => @_u.id}
    assert_equal 3000, assigns(:end)
  end
  
  def test_viewport_end_from_params_too_low
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :seq_region => @_sr.seq_id, 
                 :start_pos => 2000,
                 :end_pos => 1500}, 
                {:user => @_u.id}
    assert_equal 2001, assigns(:end)
  end
  
  def test_viewport_end_from_params_too_high
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :seq_region => @_sr.seq_id, 
                 :start_pos => 2000,
                 :end_pos => 10000}, 
                {:user => @_u.id}
    assert_equal 9000, assigns(:end)
  end
  
  def test_determine_width_from_params
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :width => 777}, 
                {:user => @_u.id}
    assert_equal 777, assigns(:width)
    assert_equal 777, session[:width]
  end
  
  def test_determine_width_from_session
    get :index, {:username => @_u.username,
                 :annotation => @_a.name}, 
                {:user => @_u.id,
                 :width => 770}
    assert_equal 770, assigns(:width)
    assert_equal 770, session[:width]
  end

  def test_determine_width_from_style
    @_s.width = 700
    @_s.save
    get :index, {:username => @_u.username,
                 :annotation => @_a.name}, 
                {:user => @_u.id}
    assert_equal 700, assigns(:width)
    assert_equal 700, session[:width]
  end

  def test_determine_width_fallback
    @_a.public = true
    @_a.save
    get :index, {:username => @_u.username,
                 :annotation => @_a.name}
    assert_equal 900, assigns(:width)
    assert_equal 900, session[:width]
  end

  def test_determine_add_introns_from_params
    get :index, {:username => @_u.username,
                 :annotation => @_a.name,
                 :add_introns => "0"}, 
                {:user => @_u.id}
    assert_equal false, assigns(:add_introns)
    assert_equal false, session[:add_introns][@_a.name]
  end
  
  def test_determine_add_introns_from_session
    get :index, {:username => @_u.username,
                 :annotation => @_a.name}, 
                {:user => @_u.id,
                :add_introns => {@_a.name => false}}
    assert_equal false, assigns(:add_introns)
    assert_equal false, session[:add_introns][@_a.name]
  end
  
  def test_determine_add_introns_from_annotation
    @_a.add_introns = false
    @_a.save
    get :index, {:username => @_u.username,
                 :annotation => @_a.name}, 
                {:user => @_u.id}
    assert_equal false, assigns(:add_introns)
    assert_equal false, session[:add_introns][@_a.name]
  end
  
end

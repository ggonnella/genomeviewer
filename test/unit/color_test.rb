require "test/test_helper.rb"
require File.dirname(__FILE__) + "/modules/gt_objects_assertions.rb"

class ColorTest < Test::Unit::TestCase

  include GTObjectsAssertions

  def test_constants
    assert Color.const_defined?("Channels")
  end

  def test_nof_arguments
    # must be 3 or 4
    assert_nothing_raised {Color.new(0.5, 0.5, 0.5)}
    assert_nothing_raised {Color.new(0.5, 0.5, 0.5, 0.5)}
    [0,1,2,5].each do |n|
      args = [0.5]*n
      assert_raises(ArgumentError) {Color.new(*args)}
    end
  end

  def test_argument_range
    assert_nothing_raised {Color.new(0.0, 0.0, 0.0)}
    assert_nothing_raised {Color.new(0.1, 0.2, 0.3)}
    assert_nothing_raised {Color.new(1.0, 1.0, 1.0)}
    assert_nothing_raised {Color.new(0.0, 0.0, 0.0, 0.5)}
    assert_nothing_raised {Color.new(0.1, 0.2, 0.3, 0.5)}
    assert_nothing_raised {Color.new(1.0, 1.0, 1.0, 0.5)}
    # underflow
    assert_raises(RangeError) {Color.new(-1.0, 0.0, 0.0)}
    assert_raises(RangeError) {Color.new(0.0, -1.0, 0.0)}
    assert_raises(RangeError) {Color.new(0.0, 0.0, -1.0)}
    assert_raises(RangeError) {Color.new(-1.0, 0.0, 0.0, 0.5)}
    assert_raises(RangeError) {Color.new(0.0, -1.0, 0.0, 0.5)}
    assert_raises(RangeError) {Color.new(0.0, 0.0, -1.0, 0.5)}
    assert_raises(RangeError) {Color.new(0.0, 0.0, 1.0, -0.5)}
    # overflow
    assert_raises(RangeError) {Color.new(2.0, 1.0, 1.0)}
    assert_raises(RangeError) {Color.new(1.0, 2.0, 1.0)}
    assert_raises(RangeError) {Color.new(1.0, 1.0, 2.0)}
    assert_raises(RangeError) {Color.new(2.0, 1.0, 1.0, 1.0)}
    assert_raises(RangeError) {Color.new(1.0, 2.0, 1.0, 1.0)}
    assert_raises(RangeError) {Color.new(1.0, 1.0, 2.0, 1.0)}
    assert_raises(RangeError) {Color.new(1.0, 1.0, 1.0, 2.0)}
  end

  def test_argument_type
    # valid
    assert_nothing_raised {Color.new(1,1,1)}
    assert_nothing_raised {Color.new("0.5","0.5","0.5")}
    assert_nothing_raised {Color.new(1,1,1,1)}
    assert_nothing_raised {Color.new("0.5","0.5","0.5","0.5")}
    # undefined
    assert_equal Color.new(nil, nil, nil), Color.new(nil, nil, nil)
    assert_equal Color.new(nil, nil, nil, nil), Color.new(nil, nil, nil, nil)
    # invalid => undefined
    assert_equal Color.new(nil, nil, nil), Color.new(1,1,"a")
    assert_equal Color.new(nil, nil, nil, nil), Color.new(1,1,"a", 1)
  end

  # according to
  # http://api.rubyonrails.org/classes/ActiveRecord/Aggregations/ClassMethods.html
  # aggregations (such as colors) should be value objects:
  #   => immutable
  #   => equality defined as equality of its fields

  def test_immutable
    assert_raises(NoMethodError) {Color.new(0,0,0).red=0.5}
    assert_raises(NoMethodError) {Color.new(0,0,0).green=0.5}
    assert_raises(NoMethodError) {Color.new(0,0,0).blue=0.5}
    assert_raises(NoMethodError) {Color.new(0,0,0).alpha=0.5}
  end

  def test_equality
    c1 = Color.new(0.0, 0.0, 0.0)
    assert_equal c1, c1
    c1a = Color.new(0.0, 0.0, 0.0, 0.0)
    assert_equal c1a, c1a
    c2 = Color.new(0.0, 0.0, 0.0)
    assert_not_equal c1.object_id, c2.object_id
    assert_equal c1, c2
    c2a = Color.new(0.0, 0.0, 0.0, 0.0)
    assert_not_equal c1a.object_id, c2a.object_id
    assert_equal c1a, c2a
    c3 = Color.new(1.0, 1.0, 1.0)
    assert_not_equal c1, c3
    assert_not_nil c1==c3
    assert_nil c1=="string"
    assert_not_equal c1, "string"
    c3a = Color.new(1.0, 1.0, 1.0, 1.0)
    assert_not_equal c1a, c3a
    assert_not_nil c1a==c3a
    assert_nil c1a=="string"
    assert_not_equal c1a, "string"
    # undefined are all equal to one another:
    assert_equal Color.new(nil, nil, nil), Color.new("a","b","c")
    assert_equal Color.new("","",""), Color.new(nil,[],{})
    assert_equal Color.new(nil, nil, nil, nil), Color.new("a","b","c","d")
    assert_equal Color.new("","","", ""), Color.new(nil,[],{},1)
  end

  def test_conversion_to_gt_color
    gvc = Color.new(0.1, 0.2, 0.3)
    gtc = gvc.to_gt
    assert_gt_color gtc
    assert_equal gvc.red, gtc.red
    assert_equal gvc.green, gtc.green
    assert_equal gvc.blue, gtc.blue
    # undefined gt color
    assert_gt_color Color.new(nil,nil,nil).to_gt
    # alpha
    gvc = Color.new(0.1, 0.2, 0.3, 0.4)
    gtc = gvc.to_gt
    assert_gt_color gtc
    assert_equal gvc.red, gtc.red
    assert_equal gvc.green, gtc.green
    assert_equal gvc.blue, gtc.blue
    assert_equal gvc.alpha, gtc.alpha
    # undefined gt color
    assert_gt_color Color.new(nil,nil,nil,nil).to_gt
  end

  def test_conversion_to_color
    [0,"a",{}].each {|x| assert_raises(ArgumentError) {Color(x)}}
    c1 = Color.new(0.1, 0.2, 0.3)
    assert_nothing_raised { Color(c1) }
    c2 = Color(c1)
    assert_not_equal c1.object_id, c2.object_id
    assert_equal c1, c2
    c1a = Color.new(0.1, 0.2, 0.3, 0.4)
    assert_nothing_raised { Color(c1a) }
    c2a = Color(c1a)
    assert_not_equal c1a.object_id, c2a.object_id
    assert_equal c1a, c2a
  end

  def test_conversion_from_gt_color
    gtc = GTServer.color_new
    gtc.red = 0.1
    gtc.green = 0.2
    gtc.blue = 0.3
    gvc = Color(gtc)
    assert_equal gtc.red, gvc.red
    assert_equal gtc.green, gvc.green
    assert_equal gtc.blue, gvc.blue
    gtc = GTServer.color_new
    gtc.red = 0.1
    gtc.green = 0.2
    gtc.blue = 0.3
    gtc.alpha = 0.4
    gvc = Color(gtc)
    assert_equal gtc.red, gvc.red
    assert_equal gtc.green, gvc.green
    assert_equal gtc.blue, gvc.blue
    assert_equal gtc.alpha, gvc.alpha
  end

  def test_undefined
    assert !Color.new(1, 1, 1).undefined?
    assert Color.new(1, 1, nil).undefined?
    assert Color.new(nil, nil, nil).undefined?
    assert_equal Color.new(nil, nil, nil), Color.undefined
    assert Color.undefined.undefined?
    assert !Color.new(1, 1, 1, 1).undefined?
    assert Color.new(1, 1, nil, 1).undefined?
    assert Color.new(nil, nil, nil, nil).undefined?
    assert_equal Color.new(nil, nil, nil, nil), Color.undefined
    assert Color.undefined.undefined?
  end

  def test_to_hex
    assert_equal '#001ACC', Color.new(0, 0.1, 0.8).to_hex
    assert_equal 'undefined', Color.new(nil, nil, nil).to_hex
    assert_equal '#001ACC00', Color.new(0, 0.1, 0.8, 0).to_hex
    assert_equal 'undefined', Color.new(nil, nil, nil, nil).to_hex
  end

  def test_from_hex
    assert_equal Color.new(0, 0, 0), '#000000'.to_color
    assert_equal Color.new(0, 1, 1), '#00fFff'.to_color
    assert_equal Color.new(nil, nil, nil), '#00000'.to_color
    assert_equal Color.new(nil, nil, nil), 'anything else'.to_color
    assert_equal Color.new(0, 0, 0, 0), '#00000000'.to_color
    assert_equal Color.new(0, 1, 1, 1), '#00fFffff'.to_color
    assert_equal Color.new(nil, nil, nil, nil), '#00000'.to_color
    assert_equal Color.new(nil, nil, nil), 'anything else'.to_color
  end

end

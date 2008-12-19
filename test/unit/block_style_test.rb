require "test/unit"
require "app/models/block_style.rb"

class BlockStyleTest < Test::Unit::TestCase

  def test_initialize
    assert_raises(ArgumentError) { BlockStyle.new() }
    [1, 2, 3.0, "4"].each {|n| assert_not_nil BlockStyle.new(n).key}
    [nil, "a", 0, 5].each {|x| assert_nil     BlockStyle.new(x).key}
  end

  def test_defined_block_styles
    assert_kind_of Hash, BlockStyle::DefinedBlockStyles
  end

  def test_string
    s = BlockStyle.new(1)
    assert_equal "box", s.string
    assert_equal "box", s.to_s
    s = BlockStyle.new(nil)
    assert_equal "undefined", s.string
  end

  # according to
  # http://api.rubyonrails.org/classes/ActiveRecord/Aggregations/ClassMethods.html
  # aggregations (such as colors) should be value objects:
  #   => immutable
  #   => equality defined as equality of its fields

  def test_immutable
    assert_raises(NoMethodError) {BlockStyle.new(1).key=2}
  end

  def test_equality
    s1 = BlockStyle.new(1)
    assert_equal s1, s1
    s2 = BlockStyle.new(1)
    assert_not_equal s1.object_id, s2.object_id
    assert_equal s1, s2
    s3 = BlockStyle.new(2)
    assert_not_equal s1, s3
    assert_not_nil s1==s3
    assert_nil s1=="string"
    assert_not_equal s1, "string"
  end

  def test_undefined
    assert_nil BlockStyle.undefined.key
  end

  def test_undefined_test
    assert BlockStyle.undefined.undefined?
  end

  def test_from_string
    assert_equal BlockStyle.new(1), "box".to_block_style
    assert_equal "undefined", "".to_block_style.to_s
  end

end

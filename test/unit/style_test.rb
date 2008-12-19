require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + "/modules/gt_objects_assertions.rb"

class StyleTest < ActiveSupport::TestCase

  include GTObjectsAssertions

  def setup
    @style = Style.create(:user_id => 1)
    # reinit style
    @style.uncache
    @style.gt
  end

  def test_there_is_a_format
    assert_not_nil @style.format
    assert_kind_of Format, @style.format
  end

  def test_section_objects_and_sections
    assert_kind_of Array, @style.sections
    assert_kind_of Array, @style.section_objects
    assert !@style.sections.empty?
    assert !@style.section_objects.empty?
    assert_equal ["format"], @style.sections
    assert_kind_of Format, @style.section_objects[0]
    ft = FeatureType.new(:name => "test")
    @style.feature_types << ft
    assert @style.section_objects.include?(ft)
    assert_equal ["format", "test"], @style.sections
  end

  def test_gt
    assert_gt_style @style.gt
  end

  def test_gt_cached
    assert GTServer.style_cached?(@style.id)
  end

  def test_uncache
    assert GTServer.style_cached?(@style.id)
    @style.uncache
    assert !GTServer.style_cached?(@style.id)
  end

  def test_gt_upload_exception
    attr = ["format","margins"]
    assert_not_equal 777.0, @style.format.margins
    assert_not_equal 777.0, GTServer.style(@style.id).get_num(*attr)
    @style.format.margins = 777.0
    @style.gt(*attr)
    assert_equal 777.0, @style.format.margins
    assert_not_equal 777.0, GTServer.style(@style.id).get_num(*attr)
    @style.uncache
    @style.gt # no exception now
    assert_equal 777.0, @style.format.margins
    assert_equal 777.0, GTServer.style(@style.id).get_num(*attr)
  end

  def test_default_gt_style
    assert_gt_style Style.default
  end

  def test_equal_img_style_new_and_default
    filename = File.expand_path("../gff3/little1.gff3",File.dirname(__FILE__))
    assert File.exist?(filename)
    args = [filename, "test1", (1000..9000), nil, # <- args[3] is style_obj
            800, true]
    args_conf_gt = args.clone
    args_conf_gt[3] = @style.gt
    args_conf_new = args.clone
    args_conf_new[3] = GTServer.style_new
    uuids = []
    [args_conf_gt, args_conf_new].each do |x| 
      uuids.push UUID.random_create.to_s
      x.unshift uuids.last
      assert GTServer.img_and_map_generate(*x)
    end    
    assert_not_nil GTServer.img(args_conf_new[0], false)
    assert_not_nil GTServer.img(args_conf_gt[0], false)
    assert_equal GTServer.img(args_conf_new[0], false), 
                 GTServer.img(args_conf_gt[0], false)
    @style.gt.set_num("format", "margins", 200.0)
    uuids.push UUID.random_create.to_s
    args_conf_gt[0] = uuids.last
    GTServer.img_and_map_generate(*args_conf_gt)
    assert_not_equal GTServer.img(args_conf_new[0], false), 
                     GTServer.img(args_conf_gt[0], false)
  ensure
    uuids.each {|x| GTServer.img_and_map_destroy(x)}
  end

end

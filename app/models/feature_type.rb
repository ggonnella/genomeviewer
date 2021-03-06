class FeatureType < ActiveRecord::Base
  include GTStyleInterface

  set_section { self.name }
  set_colors :fill, :stroke, :stroke_marked
  set_bools :collapse_to_parent, :split_lines
  set_integers :max_show_width, :max_capt_show_width, :max_num_lines,
               :bar_height, :z_index
  set_block_styles :block_style
  # TODO: add block_caption

  belongs_to :style
  has_many :feature_type_in_annotations
  has_many :annotations, :through => :feature_type_in_annotations
  validates_uniqueness_of :name, :scope => :style_id

end

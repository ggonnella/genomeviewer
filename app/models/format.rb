class Format < ActiveRecord::Base
  include GTStyleInterface

  belongs_to :style

  set_section "format"
  set_colors :track_title_color, :default_stroke_color, :background_color
  set_bools :show_grid, :show_block_captions, :show_track_captions, :split_lines
  set_floats :margins, :bar_height, :bar_vspace, :track_vspace,
         :scale_arrow_width, :scale_arrow_height, :arrow_width,
         :stroke_width, :stroke_marked_width, :min_len_block,
         :ruler_font_size, :ruler_space, :block_caption_font_size,
         :block_caption_space, :track_caption_font_size, 
         :track_caption_space

  delegate :width, :to => :style
  delegate :width=, :to => :style

  def self.helptext(attribute_name)
    case attribute_name.to_sym
      when :width then "default width of the image (px)"
      when :margins then "space left and right of diagram (px)"
      when :bar_height then "height of a feature bar (px)"
      when :bar_vspace then "space between feature bars (px)"
      when :track_vspace then "space between tracks (px)"
      when :scale_arrow_width then "width of scale arrowheads (px)"
      when :scale_arrow_height then "height of scale arrowheads (px)"
      when :arrow_width then "width of feature arrowheads (px)"
      when :stroke_width then "width of outlines (px)"
      when :stroke_marked_width then "width of outlines for marked elements (px)"
      when :show_grid then "show light vertical lines for orientation?"
      when :min_len_block then "minimum length of a block in which single elements are shown (nt)"
      when :track_title_color then "color of the track title"
      when :default_stroke_color then "default stroke color"
      when :show_block_captions then "if false, no block captions shown for any type track"
      when :ruler_font_size then "font size of the top ruler (px)"
      when :ruler_space then "vertical space between ruler and first track (px)"
      when :block_caption_font_size then "font size of the blocks captions (px)"
      when :block_caption_space then "space between a block caption and the block itself (px)"
      when :show_track_captions then "if false, no track captions shown"
      when :track_caption_font_size then "font size of the track options (px)"
      when :track_caption_space then "space between track caption and lines in the track (px)"
      when :background_color then "background color of the image"
      when :split_lines then "if false, all blocks drawn in one line per type track"
      else
	      ""
    end
  end

end

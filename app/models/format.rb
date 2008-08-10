class Format < ActiveRecord::Base
  
  belongs_to :configuration
  
  include GTRubyConfigurator 
  set_section "format"
  set_colors :track_title_color, :default_stroke_color
  set_bools :show_grid
  set_floats :margins, :bar_height, :bar_vspace, :track_vspace, 
         :scale_arrow_width, :scale_arrow_height, :arrow_width,
         :stroke_width, :stroke_marked_width, :min_len_block
  
  #
  # returns a new object with all attributes set to the default
  #
  def self.default_new
    instance = new
    configuration_attributes.each do |attr|
      instance.send("#{attr}=", instance.send("default_#{attr}"))
    end
    instance
  end
  
  def self.helptext(attribute_name)
    case attribute_name.to_sym
      when :margins : "space left and right of diagram"
      when :bar_height : "height of a feature bar"
      when :bar_vspace : "space between feature bars"
      when :track_vspace : "space between tracks"
      when :scale_arrow_width : "width of scale arrowheads"
      when :scale_arrow_height : "height of scale arrowheads"
      when :arrow_width : "width of feature arrowheads"
      when :stroke_width : "width of outlines"
      when :stroke_marked_width : "width of outlines for marked elements"
      when :show_grid : "shows light vertical lines for orientation"
      when :min_len_block : "minimum length of a block in which single elements are shown"
      when :track_title_color : "color of the track title"
      when :default_strock_color : "default stroke color"
      else
	      ""
    end
  end

end

class AddNewOptionsToFormats < ActiveRecord::Migration
  def self.up
      add_column :formats, :show_block_captions, :boolean, :default => true
      add_column :formats, :show_track_captions, :boolean, :default => true
      add_column :formats, :split_lines, :boolean, :default => true
      add_column :formats, :ruler_font_size, :float, :default => 0.0
      add_column :formats, :ruler_space, :float, :default => 0.0
      add_column :formats, :block_caption_font_size, :float, :default => 0.0
      add_column :formats, :block_caption_space, :float, :default => 0.0
      add_column :formats, :track_caption_font_size, :float, :default => 0.0
      add_column :formats, :track_caption_space, :float, :default => 0.0
      add_column :formats, :background_color_red, :float, :default => 1.0
      add_column :formats, :background_color_green, :float, :default => 1.0
      add_column :formats, :background_color_blue, :float, :default => 1.0
  end

  def self.down
      remove_column :formats, :show_block_captions 
      remove_column :formats, :ruler_font_size 
      remove_column :formats, :ruler_space 
      remove_column :formats, :block_caption_font_size 
      remove_column :formats, :block_caption_space 
      remove_column :formats, :show_track_captions 
      remove_column :formats, :track_caption_font_size 
      remove_column :formats, :track_caption_space 
      remove_column :formats, :background_color_red
      remove_column :formats, :background_color_green
      remove_column :formats, :background_color_blue
      remove_column :formats, :split_lines 
  end
end

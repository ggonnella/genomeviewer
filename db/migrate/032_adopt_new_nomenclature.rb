class AdoptNewNomenclature < ActiveRecord::Migration

  def self.up
    rename_table :configurations, :styles
    rename_column :feature_types, :configuration_id, :style_id
    rename_column :feature_types, :style_key, :block_style_key
    rename_column :formats, :configuration_id, :style_id
 end
  
  def self.down
    rename_table :styles, :configurations
    rename_column :feature_types, :style_id, :configuration_id
    rename_column :feature_types, :block_style_key, :style_key
    rename_column :formats, :style_id, :configuration_id
  end

end

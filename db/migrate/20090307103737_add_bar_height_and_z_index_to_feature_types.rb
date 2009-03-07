class AddBarHeightAndZIndexToFeatureTypes < ActiveRecord::Migration
  def self.up
    add_column :feature_types, :bar_height, :integer, :default => 15
    add_column :feature_types, :z_index, :integer, :defautl => nil
  end

  def self.down
    remove_column :feature_types, :bar_height
    remove_column :feature_types, :z_index
  end
end

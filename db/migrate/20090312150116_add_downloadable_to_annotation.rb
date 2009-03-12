class AddDownloadableToAnnotation < ActiveRecord::Migration
  def self.up
    add_column :annotations, :downloadable, :boolean
  end

  def self.down
    remove_column :annotations, :downloadable
  end
end

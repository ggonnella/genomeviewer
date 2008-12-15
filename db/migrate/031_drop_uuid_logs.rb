class DropUuidLogs < ActiveRecord::Migration
  
  def self.up
    drop_table :uuid_logs
  end
  
  def self.down
    create_table :uuid_logs do |t|
      t.string   :uuid, :limit => 36
      t.text     :args
      t.datetime :created_at
    end
    add_index :uuid_logs, :uuid
    add_index :uuid_logs, :created_at
  end
end
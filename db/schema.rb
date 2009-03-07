# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090307103737) do

  create_table "annotations", :force => true do |t|
    t.string  "name",        :default => "",    :null => false
    t.integer "user_id",     :default => 0,     :null => false
    t.text    "description", :default => ""
    t.boolean "public",      :default => false, :null => false
    t.boolean "add_introns", :default => true,  :null => false
  end

  create_table "feature_type_in_annotations", :force => true do |t|
    t.integer "annotation_id",       :default => 0
    t.integer "feature_type_id",     :default => 0
    t.integer "max_show_width",      :default => 0
    t.integer "max_capt_show_width", :default => 0
  end

  create_table "feature_types", :force => true do |t|
    t.string  "name",                :default => ""
    t.float   "fill_red",            :default => 0.0
    t.float   "fill_green",          :default => 0.0
    t.float   "fill_blue",           :default => 0.0
    t.float   "stroke_red",          :default => 0.0
    t.float   "stroke_green",        :default => 0.0
    t.float   "stroke_blue",         :default => 0.0
    t.float   "stroke_marked_red",   :default => 0.0
    t.float   "stroke_marked_green", :default => 0.0
    t.float   "stroke_marked_blue",  :default => 0.0
    t.integer "block_style_key",     :default => 0
    t.boolean "collapse_to_parent",  :default => false
    t.boolean "split_lines",         :default => false
    t.integer "max_capt_show_width", :default => 0
    t.integer "max_num_lines",       :default => 0
    t.integer "style_id",            :default => 0
    t.integer "max_show_width",      :default => 0
    t.integer "bar_height",          :default => 15
    t.integer "z_index",             :default => 0
  end

  create_table "formats", :force => true do |t|
    t.float   "margins",                    :default => 0.0
    t.float   "bar_height",                 :default => 0.0
    t.float   "bar_vspace",                 :default => 0.0
    t.float   "track_vspace",               :default => 0.0
    t.float   "scale_arrow_width",          :default => 0.0
    t.float   "scale_arrow_height",         :default => 0.0
    t.float   "arrow_width",                :default => 0.0
    t.float   "stroke_width",               :default => 0.0
    t.float   "stroke_marked_width",        :default => 0.0
    t.boolean "show_grid",                  :default => false
    t.float   "min_len_block",              :default => 0.0
    t.float   "track_title_color_red",      :default => 0.0
    t.float   "track_title_color_green",    :default => 0.0
    t.float   "track_title_color_blue",     :default => 0.0
    t.float   "default_stroke_color_red",   :default => 0.0
    t.float   "default_stroke_color_green", :default => 0.0
    t.float   "default_stroke_color_blue",  :default => 0.0
    t.integer "style_id",                   :default => 0
  end

  create_table "sequence_regions", :force => true do |t|
    t.string  "seq_id",        :default => "", :null => false
    t.integer "annotation_id", :default => 0,  :null => false
    t.integer "seq_begin",     :default => 0,  :null => false
    t.integer "seq_end",       :default => 0,  :null => false
    t.text    "description",   :default => ""
  end

  create_table "styles", :force => true do |t|
    t.integer "user_id", :default => 0
    t.integer "width",   :default => 800, :null => false
  end

  create_table "users", :force => true do |t|
    t.string  "password",                 :limit => 40, :default => "", :null => false
    t.string  "name",                     :limit => 64, :default => "", :null => false
    t.string  "email",                    :limit => 64, :default => "", :null => false
    t.string  "institution",                            :default => ""
    t.string  "url",                                    :default => ""
    t.integer "public_annotations_count",               :default => 0,  :null => false
    t.string  "username",                 :limit => 64, :default => "", :null => false
  end

end

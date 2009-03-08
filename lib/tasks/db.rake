namespace :db do 
  namespace :example_user do 
    desc "Load default user in the database"
    task :load => :environment do 
      file = "db/default_data/example_user.yml"
      example_user = YAML.load(IO.read file)
      puts "-- create example user foo/foo"
      u = User.create(example_user)
      puts "   -> done"
      puts "-- upload gff3 files under test/gff3"
      filenames =  Dir.glob("test/gff3/**.gff3")
      filenames.each do |f|
        Annotation.new do |a|
          a.name = File.basename(f)
          a.user = u
          a.gff3_data = IO.read(f)
          a.save
        end
        puts "   -> #{File.basename(f)} uploaded"
      end
    end
  end
  namespace :guest_user do 
    desc "Load standard guest user in the database"
    task :load => :environment do 
      file = "db/default_data/guest_user.yml"
      guest_user = YAML.load(IO.read file)
      puts "-- create guest user"
      u = User.create(guest_user)
      puts "   -> done"
    end
  end
  desc "Load schema (db:schema:load) and guest user"
  task :load => ["db:schema:load", "db:fix_defaults", "db:guest_user:load"]
  desc "Create the db schema and load example and guest users"
  task :load_with_foo => ["db:load", "db:example_user:load"]
  desc "Run a fix for the consequences of a sqlite3 adapter bug"
  task :fix_defaults => :environment do 
    puts "-- dropping feature_type_in_annotations"
    drop_sql = 'DROP TABLE "feature_type_in_annotations";'
    puts "   -> done"
    puts "-- recreating feature_type_in_annotations with correct default values"
    create_sql = 'CREATE TABLE "feature_type_in_annotations" (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        "annotation_id" integer DEFAULT 0,
        "feature_type_id" integer DEFAULT 0,
        "max_show_width" integer default null,
        "max_capt_show_width" integer default null
      );'
    puts "   -> done"
    ActiveRecord::Base.connection.execute drop_sql
    ActiveRecord::Base.connection.execute create_sql
  end
end


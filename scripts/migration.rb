
require 'sequel'
require 'yaml'
require "sequel/extensions/migration"
require 'optparse'
require 'yaml'

def config_to_url(c)
    "mysql2://#{c['username']}:#{c['password']}@#{c['host']}:#{c['port'] || 3306}/#{c['database']}"
end

def db_execute(db_config, cmd)
    db = Sequel.connect(db_config)
    db.execute cmd
    db.disconnect
end

def create_db_if_not_exist(db_config)
    nodb_config = db_config.clone()
    database = nodb_config.delete('database')
    db_execute nodb_config, "CREATE DATABASE IF NOT EXISTS #{database} CHARACTER SET utf8 COLLATE utf8_general_ci;"
end

def connect_with_createdb(db_config)
    begin
        db = Sequel.connect(db_config)
    rescue Sequel::DatabaseConnectionError => e
        if e.message.downcase.include? 'unknown database'
            puts 'warn: db not exist, auto create...'
            create_db_if_not_exist(db_config)
            db = Sequel.connect(db_config)
        else
            raise e
        end
    end
    db
end

def set_lib(dir)
    $:.unshift(dir) if File.directory?(dir)
end

def db_migrate(db, migrations_folder)
    begin
      Sequel::Migrator.check_current(db, migrations_folder)
    rescue Sequel::Migrator::Error
      Sequel::Migrator.run(db, migrations_folder)
    end
end

#start script
Options = Struct.new(:mdir, :yml_file, :lib_dir, :db_config)
default_dir = Dir.pwd
args = Options.new()
args.mdir = File.join(default_dir, 'db', 'migrations')
args.yml_file = File.join(default_dir, 'config', 'database.yml')
args.lib_dir = File.join(default_dir, 'lib')
args.db_config = nil
env = ENV["RAILS_ENV"] || 'test'
    
OptionParser.new do |opts|
    opts.banner = "Usage: migration.rb [options]"

    opts.on("-mMDIR", "--mdir=MDIR", "Migration Folder") do |folder|
        args.mdir = folder
    end

    opts.on("-yYAML_CONFIG", "--yml_file=YAML_CONFIG", "database yaml config") do |yml_file|
        args.yml_file = yml_file
    end

    opts.on("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
end.parse!


#checking options
puts 'Yaml File not exist' and exit unless File.exist?(args.yml_file)
args.db_config = YAML.load_file(args.yml_file)[env]

puts 'Migration Folder not exist' and exit unless File.directory?(args.mdir)

puts "Connecting Database..."
db = connect_with_createdb(args.db_config)
set_lib(args.lib_dir) #for migration utils function
puts "Running Migrate..."
db_migrate(db, args.mdir)
puts "Run Migrate Completed"
task :default => %i[
  mkdirs
  init_db
]

desc 'makes dirs specified in config'
task :mkdirs do
  require 'pathname'
  require_relative 'lib/config_file'
  config = ConfigFile.read

  path = config.collections_dir
  config.collections.each { |x|
    dir = x.id
    (Pathname(path) + dir).mkpath
  }
end

desc 'db structure'
task :init_db do
  require_relative 'lib/state'
  DB.create_table :last_known_update do
    primary_key :id
    String :updated_id
    Date   :known_update
    Date   :created_at
  end
end

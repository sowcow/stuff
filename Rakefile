task :default => :mkdirs

desc 'makes dirs specified in config'
task :mkdirs do
  require 'pathname'
  require_relative 'lib/config_file'
  config = ConfigFile.read

  path = config.collections_dir
  config.collections.each { |x|
    (Pathname(path) + x.dir).mkpath
  }
end

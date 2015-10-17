require 'toml'
require_relative 'config_struct'
require 'forwardable'



class ConfigFile
  def self.read file = 'config.toml'
    new File.read file
  end

  def self.new config
    ConfigStruct.new TOML.parse config
  end

#  def initialize config
#    @config = ConfigStruct.new TOML.parse config
#  end
#
#  extend Forwardable
#  delegate [ :collections ] => :@config
end


if __FILE__ == $0
  subj = ConfigFile

  one = subj.new <<-text
    
    [[collections]]
    
      slug = 'alfa'
      some_info = 123
    
    [[collections]]
    
      slug = 'beta'
      some_info = 456
    
  text


  raise unless one.collections.count == 2
  raise unless one.collections.first.slug == 'alfa'
  puts :OK
end

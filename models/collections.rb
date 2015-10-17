class Collections
  def self.all config
    config.collections.map { |collection_cfg|
      Collections.new collection_cfg
    }
  end

  def initialize config

  end
end

class Collections
  def self.all config
    config.collections.map { |collection_cfg|
      Collections.new collection_cfg
    }
  end

  def initialize config
    load_config config
  end

  PROPS = %i[
    id
    name
    server
  ]

  attr_reader *PROPS

  private

  def load_config config
    PROPS.each { |name|
      value = config.__send__(name)
      instance_variable_set "@#{name}", value
    }
  end

  def last_update
    State.last_update dir
  end

  def dir;  id end
  def slug; id end

end

if __FILE__== $0
end

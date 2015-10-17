class ConfigStruct < BasicObject
  Hash = ::Hash
  Array = ::Array
  ThisClass = ::ConfigStruct

  def initialize hash
    hash.each { |key, value|
      value = ThisClass.may_cloth value

      instance_eval "
        @#{key} = value

        def self.#{key}
          @#{key}
        end
      "
    }
  end

  def self.may_cloth thing
    case thing
    when Array then thing.map { |x| may_cloth x }
    when Hash then new thing
    else
      thing
    end
  end
end


if __FILE__ == $0
  subj = ConfigStruct
  subj.new(a: 1).a == 1 or raise
  subj.new(a: {b: 1}).a.b == 1 or raise

  # subj.new(a: 1).methods
  #  - nope, end points should be known,
  #    not just enumerated
  #  - but on a nested levels
  #  - should be just arrays of hashes (toml or so)

  puts :OK
end

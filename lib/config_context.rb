class ConfigContextBuilder
  def initialize hash
    @hash = hash
  end

  def build
    Object.new.instance_eval {
      define_singleton_method :a do 1 end
      self
    }
  end
end


C = ConfigContextBuilder


puts :OK if C.new(a: 1).build.a == 1

__END__
class ConfigContext

  def self.from_hash hash, path = []
    nodes = {} # level,index => Object
    stack = []

    levels = Hash.new do |hash, key| hash[key] = [] end

    pairs = hash.each_pair.to_a
    hashes, arrays, values = pairs.group_by { |k,v|
      case v
      when Hash then
    }.values
    arrays = pairs.select { |k,v| v.is_a? Array }.uniq
    arrays = pairs.select { |k,v| v.is_a? Array }.uniq
  end

  def initialize hash, level
  end
end


if __FILE__ == $0
  ConfigContext.from_hash a: { b: 1, c: 2, d: { e: 3 } }
end

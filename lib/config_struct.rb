class ConfigStruct
  TheClass = ::ConfigStruct

  def initialize hash, parent = nil
    @__keys__ = []
    @__parent__ = parent
    @__children__ = children = []

    pairs = hash.to_a
    groups = pairs.group_by { |key, value|
      case value
      when Hash  then :hashes
      when Array then :arrays
      else
        :values
      end
    }
    values = groups[:values] || []
    hashes = groups[:hashes] || []
    #arrays = groups[:arrays] || []
    
    values.each { |key, value|
      TheClass.inject_value self, key, value
    }
    hashes.each { |key, hash|
      object = TheClass.new hash, self
      children << object
      TheClass.inject_value self, key, object
    }
    #arrays.each { |key, array|
    #  TheClass.inject_value self, key, array
    #}
    
    if parent.nil?
      # after all objects been created

      children.each { |child|
        TheClass.let_child_delegate_missing child: child
      }
    end
  end

  def __keys__
    @__keys__
  end
  
  # class methods
  class << self

    def inject_value object, key, value
      object.__keys__ << key
      object.instance_eval "
        @#{key} = value

        def #{key}
          @#{key}
        end
      "
    end


    def delegate_value on:, key:, to:;
      on.instance_eval "
        @__keys__ << key

        @_delegate_#{key}_to = to

        def #{key}
          @_delegate_#{key}_to.__send__ :#{key}
        end
      "
    end

    def let_child_delegate_missing child:;
      parent = child.instance_eval { @__parent__ }

      missing_keys = parent.__keys__ - child.__keys__
      missing_keys.each { |key|
        TheClass.delegate_value on: child, key: key, to: parent
      }

      child.instance_eval { @__children__ }
      .each { |x| let_child_delegate_missing child: x }
      # delegate missing to it!
    end
    #  eval " def object.#{key}; value end "
    #end

    #def introduce_hash object, key, value
    #  object.instance_eval "
    #    @#{key} = value

    #    def object.#{key}
    #      @#{key}
    #    end
    #  "
    #end

  end
end


if __FILE__ == $0
  #p ConfigStruct.new(a: '123', b: { c: 123 }).b.c
  p ConfigStruct.new(a: '123', b: { c: 123, d: { e: 1} }).b.d.a
end


__END__
$id = 0

class ConfigStruct < BasicObject
  Hash = ::Hash
  Array = ::Array
  ThisClass = ::ConfigStruct

  #def self.build hash
  #end
  
  def id
    @id
  end

  def initialize hash, parent = nil
    @id = ($id += 1)
    ::Kernel.p "it: #{@id}"
    ::Kernel.p "parent: #{parent.id}" rescue nil

    # this stuff used for "inheritance of context" as I called it...
    # you can say that each child have value as if it was merged into the parent
    # so it can overwrite, but anyway carry all all other stuff
    #@parent = nil
    @children = []
    @keys = []

    #hash = context.merge hash
    #@struct_keys = []
    #if parent == NOPE_IT_IS_ROOT
    #  # nothing
    #else
    ThisClass.assign_children parent: parent, child: self
    #end

    hash.each { |key, value|
      value = ThisClass.may_cloth value: value, parent: self
      
      omg = value.id rescue false
      if omg
        ::Kernel.p "key: #{key}, id: #{omg}"
      end

      @keys << key
      instance_eval "
        @#{key} = value

        def self.#{key}
          @#{key}
        end
      "
    }

    root = parent == nil  # can't .nil? on BasicObject and `not !!` is alot


    if root
      ::Kernel.p "x-root: #{@id}"
      @children.each { |child|
        ThisClass.inherit_missing_keys parent: self, child: child
      }
    end
    #  hash.each { |key, value|
    #    if __send__(key).class < ThisClass
    #      ThisClass.delegate_missing from: __send__(key), to: self, keys: @keys
    #    end
    #  }
    #end
  end

  def __keys__
    @keys
  end

  def self.may_cloth value:, parent:;
    thing = value
    case thing
    when Array then thing.map { |x| may_cloth x, context }
    when Hash then new thing, parent
    else
      thing
    end
  end

  def self.delegate_missing from:, to:, keys:;
    from_keys = from.__send__('__keys__')
    to_keys = keys
    missing = to_keys - from_keys
    p missing
  end

  def self.assign_children parent:, child:;
    return unless parent
    #child.instance_eval {
    #  @parent = parent
    #}
    ::Kernel.p "x-child: #{child.id}"
    ::Kernel.p "x-parent: #{parent.id}"
    parent.instance_eval {
      @children << child
    }
  end

  def self.inherit_missing_keys parent:, child:;
    p 123
    parent_keys, child_keys = [parent, child].map { |x| x.__send__ '__keys__' }
    missing_in_child = parent_keys - child_keys

    #require 'pry'; binding.pry
    #p "#{from.id} - #{to.id}"
    #p missing_in_child
    missing_in_child.each { |key|
      ::Kernel.p "adding-#{key}-to-#{child.id}"
      child.instance_eval "
        def #{key}
          @parent.__send__ :#{key}
        end
      "
    }
    #p [from.id, to.id]
    #p from_keys
    #p to_keys
  end
end


if __FILE__ == $0
  subj = ConfigStruct
  #subj.new(a: 1).a == 1 or raise
  #subj.new(a: {b: 1}).a.b == 1 or raise
  struct = { x: 0, a: {b: {c: 1}} }
  #subj.new(struct).a.b.c == 1 or raise
  #subj.new(struct).x == 0 or raise
  subj.new(struct).a.x == 0 or raise
  #subj.new(a: {b: {c: 1}}).a.b.c == 1 or raise

  # (subj.new(a: {b: 1}).a.b.b rescue :err) == :err or raise

  # subj.new(a: {b: {c: 1}}).a
  # p subj.new(a: {b: {c: 1}}).a.b.c
  # subj.new(a: {b: {c: 1}}).a.b.c == 1 or raise
  # subj.new(a: {b: {c: 1}}).a.b.a.b.b.c == 1 or raise


  # subj.new(a: 1).methods
  #  - nope, end points should be known,
  #    not just enumerated
  #  - but on a nested levels
  #  - should be just arrays of hashes (toml or so)

  puts :OK
end

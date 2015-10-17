class Hash
  def split_into_values_hashes_arrays
    hash = self

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
    arrays = groups[:arrays] || []

    [ values, hashes, arrays ]
  end
end


class Object
  def self.delegate_value on:, key:, to:;
    on.instance_eval "
      @__keys__ << key

      @_delegate_#{key}_to = to

      def #{key}
        @_delegate_#{key}_to.__send__ :#{key}
      end
    "
  end

  def self.delegate_missing_to_parent child
    right_object7 = !! child.__keys__ rescue false
    return unless right_object7

    parent = child.instance_eval { @__parent__ }

    missing_keys = parent.__keys__ - child.__keys__
    missing_keys.each { |key|
      Object.delegate_value on: child, key: key, to: parent
    }

    child.instance_eval { @__children__ }
    .each { |x| x.delegate_missing_to_parent }
  end
end


class AsObjectChild

  def initialize object
    @object = object
  end

  def delegate_missing_to_parent
    Object.delegate_missing_to_parent @object
  end

end


class AsArrayChild

  def initialize array
    @array = array
  end

  def delegate_missing_to_parent
    @array.flatten.each { |thing|
      Object.delegate_missing_to_parent thing
    }
  end

end


class ConfigStruct
  TheClass = ::ConfigStruct

  def initialize hash, parent = nil
    @__keys__ = []
    @__parent__ = parent
    @__children__ = children = []

    (values, hashes, arrays) = hash.split_into_values_hashes_arrays
    
    values.each { |key, value|
      TheClass.inject_value self, key, value
    }
    hashes.each { |key, child_hash|
      object = TheClass.new child_hash, self
      children << AsObjectChild.new(object)
      TheClass.inject_value self, key, object
    }
    arrays.each { |key, array|
      array = TheClass.recursive_process_array array, self
      children << AsArrayChild.new(array)
      TheClass.inject_value self, key, array
    }
    
    if parent.nil?  # (after all objects been created)
      children.each { |child|
        child.delegate_missing_to_parent
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

    def recursive_process_array array, parent
      array.map { |element|
        case element
        when Array then recursive_process_array element, parent
        when Hash  then TheClass.new element, parent
        else
          element
        end
      }
    end
  end
end


if __FILE__ == $0
  require 'maxitest/autorun'


  describe ConfigStruct do
    def subj; ConfigStruct end

    it 'provides nice access to hashes' do
      subj.new(a: 123).a.must_equal 123
    end

    it 'provides nice access to nested hashes' do
      subj.new(a: 123, b: { c: 456 }).b.c.must_equal 456
    end

    it 'most notably inherits values from parent hashes into child ones' do
      subj.new(
        a: 123,
        b: {
          c: 456,
          d: { e: 789 }
        }
      ).tap { |subj|
        subj.b.d.e.must_equal 789
        subj.b.d.c.must_equal 456
        subj.b.d.a.must_equal 123

        subj.b.b.b.b.a.must_equal 123

        subj.b.d
            .b.d
            .b.d
            .c.must_equal 456
      }
    end

    specify 'so you can access even values from sibling key' do
      subj.new(
        a: 123,
        b: {}
      ).tap { |subj|
        subj.b.a.must_equal 123
      }
    end

    specify 'but you can\'t jump straight to deep child values' do
      subj.new(
        a: 123,
        b: {
          c: {
            d: 456
          }
        }
      ).tap { |subj|
        (subj.b.d rescue :err).must_equal :err
      }
    end

    specify 'so you can think of nested elements as extensions of parent ones' do
      subj.new(
        behave: 'normal',
        mean_weather: {
          behave: 'mean',
          warm_fireplace: {
            behave: 'warm'
          },
        }
      ).tap { |subj|
        subj.behave.must_equal 'normal'
        subj.mean_weather.behave.must_equal 'mean'
        subj.mean_weather.warm_fireplace.behave.must_equal 'warm'
      }
    end

    specify 'in nested arrays hashes are also processed and linherit' do
      subj.new(
        a: 123,
        n: [
          123,
          456,
          { x: 1 }
        ],
        x: [
          [
            [
              { y: 'found' },
            ]
          ]
        ]
      ).tap { |subj|
        subj.x[0][0][0].y.must_equal 'found'
        subj.x[0][0][0].n.last.x.must_equal 1
      }
    end

    #specify '' do
    #end
  end
end

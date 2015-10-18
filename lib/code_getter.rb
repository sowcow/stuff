require_relative 'last_known_update'

class DDL_Getter
  def initialize thing
  end

  def get objects:;
    objects.map { |x|
      if [*1..100].sample == 1
        [*?a..?z].sample(10).join
      else
        'mostly stable content'
      end
    }
  end
end


require 'pathname'
require 'forwardable'


class CodeGetter
  def self.for thing
    getter = 
      case thing.getter
      when 'ddl'
        DDL_Getter.new thing
      else raise
      end
    new thing: thing, getter: getter
  end

  def initialize thing:, getter:;
    @thing = thing
    @getter = getter
  end

  def get
    dir = Pathname @thing.dir

    last_updated = LastKnownUpdate.for(id)

    session thing.server do
      objects = plsql.dba_objects "
        where object_type #{in_ object_types}
        and last_ddl_time >= :1
      ", last_updated

      objects = @getter.get objects: objects
      objects.each { |name, content|
        (dir + file).open ?w do |file|
          file.write content
        end
      }
    end
  end

  extend Forwardable
  delegate %i[
    id
    object_types
  ] => :@thing

#  def initialize server:, dir:, id:;
#    @server = server
#    @dir    = dir
#    @id     = id
#  end
#
#  def get
#    session @server do
#      objects = plsql.
#    end
#    LastUpdate.for(id)
#  end
end

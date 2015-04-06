require "java" if RUBY_ENGINE == "jruby"

#A simple weak-reference framework with mapping. Only handles the referencing of objects.
#===Examples
# user_obj = ob.get(:User, 1)
# weak_ref = Wref.new(user_obj)
# user_obj = nil
# sleep 0.5
# GC.start
#
# begin
#   user_obj = weak_ref.get
#   print "The user still exists in memory and has ID #{user.id}."
# rescue Wref::Recycled
#   print "The user has been removed from memory."
# end
class Wref
  #This error is raised when an object in a wref has been garbage-collected.
  class Recycled < RuntimeError; end

  autoload :Map, "#{File.dirname(__FILE__)}/wref/map"

  #Returns the classname of the object.
  attr_reader :class_name

  #Returns the object-ID which is used to look up the ObjectSpace (if not running JRuby).
  attr_reader :id

  #This can be used to debug the behavior of the library.
  USE_NATIVE_RUBY_IMPLEMENTATION = false

  #Initializes various variables.
  def initialize(obj)
    if USE_NATIVE_RUBY_IMPLEMENTATION
      require "weakref"
      @weakref = WeakRef.new(obj)
    elsif RUBY_ENGINE == "jruby"
      @weakref = java.lang.ref.WeakReference.new(obj)
    else
      @id = obj.__id__
      @class_name = obj.class.name.to_sym
      ObjectSpace.define_finalizer(obj, method(:destroy))

      if obj.respond_to?(:__wref_unique_id__)
        @unique_id = obj.__wref_unique_id__
      end
    end
  end

  #Destroyes most variables on the object, releasing memory and returning 'Wref::Recycled' all the time. It takes arguments because it can be called from destructor of the original object. It doesnt use the arguments for anything.
  def destroy(*args)
    @id = nil
    @class_name = nil
    @unique_id = nil
    @weakref = nil
  end

  #Returns the object that this weak reference holds or raises Wref::Recycled.
  # begin
  #   obj = wref.get
  #   print "Object still exists in memory."
  # rescue Wref::Recycled
  #   print "Object has been garbage-collected."
  # end
  def get
    begin
      if USE_NATIVE_RUBY_IMPLEMENTATION
        begin
          return @weakref.__getobj__
        rescue => e
          raise Wref::Recycled if e.class.name == "RefError"
          raise e
        end
      elsif RUBY_ENGINE == "jruby"
        raise Wref::Recycled unless @weakref
        obj = @weakref.get

        if obj == nil
          raise Wref::Recycled
        else
          return obj
        end
      else
        raise Wref::Recycled if !@class_name or !@id
        obj = ObjectSpace._id2ref(@id)

        #Some times this class-name will be nil for some reason - knj
        obj_class_name = obj.class.name

        if !obj_class_name || @class_name != obj_class_name.to_sym || @id != obj.__id__
          raise Wref::Recycled
        end

        if @unique_id
          raise Wref::Recycled if !obj.respond_to?(:__wref_unique_id__) || obj.__wref_unique_id__ != @unique_id
        end

        return obj
      end
    rescue RangeError, TypeError
      raise Wref::Recycled
    end
  end

  #The same as the normal 'get' but returns nil instead of raising Wref::Cycled-error.
  def get!
    begin
      return self.get
    rescue Wref::Recycled
      return nil
    end
  end

  #Returns true if the reference is still alive.
  # print "The object still exists in memory." if wref.alive?
  def alive?
    begin
      self.get
      return true
    rescue Wref::Recycled
      return false
    end
  end

  #Makes Wref compatible with the normal WeakRef.
  alias weakref_alive? alive?
  alias __getobj__ get
end

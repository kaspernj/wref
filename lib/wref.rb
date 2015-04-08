require "weakref"

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

  class Implementations
    dir = "#{File.dirname(__FILE__)}/wref/implementations"

    autoload :IdClassUnique, "#{dir}/id_class_unique"
    autoload :JavaWeakReference, "#{dir}/java_weak_reference"
    autoload :Ref, "#{dir}/ref"
    autoload :Weakling, "#{dir}/weakling"
    autoload :WeakRef, "#{dir}/weak_ref"
  end

  attr_reader :implementation, :weak_ref

  #Initializes various variables.
  def initialize(object, args = {})
    if args[:impl]
      @implementation = args[:impl]
    elsif RUBY_ENGINE == "jruby"
      @implementation = :JavaWeakReference
    else
      @implementation = :IdClassUnique
    end

    @weak_ref = Wref::Implementations.const_get(implementation).new(object)
  end

  #Returns the object that this weak reference holds or raises Wref::Recycled.
  # begin
  #   object = wref.get!
  #   puts "Object still exists in memory."
  # rescue Wref::Recycled
  #   puts "Object has been garbage-collected."
  # end
  def get!
    @weak_ref.get!
  end

  #The same as the normal 'get!' but returns nil instead of raising Wref::Cycled-error.
  def get
    @weak_ref.get
  end

  #Returns true if the reference is still alive.
  # print "The object still exists in memory." if wref.alive?
  def alive?
    @weak_ref.alive?
  end

  #Makes Wref compatible with the normal WeakRef.
  alias weakref_alive? alive?
  alias __getobj__ get
end

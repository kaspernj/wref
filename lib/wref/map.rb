#A weak hash-map.
#===Examples
# map = Wref::Map.new
# map[1] = obj
# obj = nil
#
# sleep 0.5
#
# begin
#   obj = map[1]
#   print "Object still exists in memory."
# rescue Wref::Recycled
#   print "Object has been garbage-collected."
# end
#
# obj = map.get(1)
# print "Object still exists in memory." if obj
class Wref::Map
  def initialize(args = {})
    require "monitor"

    @map = {}
    @mutex = Monitor.new
    @impl = args[:impl]
  end

  #Sets a new object in the map with a given ID.
  def set(id, obj)
    wref = Wref.new(obj, impl: @impl)

    @mutex.synchronize do
      @map[id] = wref
    end

    return nil
  end

  #Returns an object by ID or raises a RefError.
  #===Examples
  # begin
  #   obj = map.get!(1)
  #   print "Object still exists in memory."
  # rescue Wref::Recycled
  #   print "Object has been garbage-collected."
  # end
  def get!(id)
    wref = nil
    @mutex.synchronize do
      raise Wref::Recycled unless @map.key?(id)
      wref = @map[id]
    end

    if object = wref.get
      return object
    else
      delete(id)
      raise Wref::Recycled
    end
  end

  #The same as 'get!' but returns nil instead of WeakRef-error. This can be used to avoid writing lots of code.
  #===Examples
  # obj = map.get(1)
  # print "Object still exists in memory." if obj
  def get(id)
    begin
      return get!(id)
    rescue Wref::Recycled
      return nil
    end
  end

  #Scans the whole map and removes dead references. After the implementation of automatic clean-up by using ObjectSpace.define_finalizer, there should be no reason to call this method.
  def clean
    keys = nil
    @mutex.synchronize do
      keys = @map.keys
    end

    keys.each do |key|
      begin
        get(key) #this will remove the key if the object no longer exists.
      rescue Wref::Recycled
        #ignore.
      end
    end

    return nil
  end

  #Returns true if a given key exists and the object it holds is alive.
  def valid?(key)
    @mutex.synchronize do
      return false unless @map.key?(key)
    end

    begin
      @map[key].get
      return true
    rescue Wref::Recycled
      return false
    end
  end

  #Returns true if the given key exists in the hash.
  #===Examples
  # print "Key exists but we dont know if the value has been garbage-collected." if map.key?(1)
  def key?(key)
    @mutex.synchronize do
      if @map.key?(key) && get(key)
        return true
      else
        return false
      end
    end
  end

  #Returns the length of the hash. This may not be true since invalid objects is also counted.
  def length
    @mutex.synchronize do
      return @map.length
    end
  end

  #Cleans the hash and returns the length. This is slower but more accurate than the ordinary length that just returns the hash-length.
  def length_valid
    clean
    return length
  end

  #Deletes a key in the hash.
  def delete(key)
    @mutex.synchronize do
      wref = @map[key]
      object = @map.delete(key)

      if object
        return object.get
      else
        return nil
      end
    end
  end

  #Iterates over every valid object in the weak map.
  #===Examples
  # map.each do |obj|
  #   puts "Object alive: #{obj}"
  # end
  def each(&block)
    enum = Enumerator.new do |yielder|
      ids = nil
      @mutex.synchronize do
        ids = @map.keys
      end

      ids.each do |id|
        if obj = get(id)
          yielder << [id, obj]
        end
      end
    end

    if block
      enum.each(&block)
    else
      return enum
    end
  end

  #Make it hash-compatible.
  alias has_key? key?
  alias [] get
  alias []= set
end

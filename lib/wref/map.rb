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
# obj = map.get!(1)
# print "Object still exists in memory." if obj
class Wref::Map
  def initialize(args = nil)
    @map = {}
    @ids = {}
    @mutex = Mutex.new
  end

  #Sets a new object in the map with a given ID.
  def set(id, obj)
    wref = Wref.new(obj)

    @mutex.synchronize do
      @map[id] = wref
      @ids[obj.__id__] = id
    end

    #JRuby cant handle this atm... Dunno why...
    if RUBY_ENGINE != "jruby"
      ObjectSpace.define_finalizer(obj, self.method(:delete_by_id))
    end

    return nil
  end

  #Returns a object by ID or raises a RefError.
  #===Examples
  # begin
  #   obj = map[1]
  #   print "Object still exists in memory."
  # rescue Wref::Recycled
  #   print "Object has been garbage-collected."
  # end
  def get(id)
    begin
      wref = nil
      @mutex.synchronize do
        raise Wref::Recycled if !@map.key?(id)
        wref = @map[id]
      end

      return wref.get
    rescue Wref::Recycled => e
      self.delete(id)
      raise e
    end
  end

  #The same as 'get' but returns nil instead of WeakRef-error. This can be used to avoid writing lots of code.
  #===Examples
  # obj = map.get!(1)
  # print "Object still exists in memory." if obj
  def get!(id)
    begin
      return self.get(id)
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
        self.get(key) #this will remove the key if the object no longer exists.
      rescue Wref::Recycled
        #ignore.
      end
    end

    return nil
  end

  #Returns true if a given key exists and the object it holds is alive.
  def valid?(key)
    @mutex.synchronize do
      return false if !@map.key?(key)
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
      return @map.key?(key)
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
    self.clean
    return self.length
  end

  #Deletes a key in the hash.
  def delete(key)
    @mutex.synchronize do
      wref = @map[key]
      @ids.delete(wref.id) if wref
      return @map.delete(key).get!
    end
  end

  #This method is supposed to remove objects when finalizer is called by ObjectSpace.
  def delete_by_id(object_id)
    @mutex.synchronize do
      id = @ids[object_id]
      @ids.delete(object_id)
      return @map.delete(id).get!
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
        if obj = self.get!(id)
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
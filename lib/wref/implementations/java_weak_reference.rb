class Wref::Implementations::JavaWeakReference
  def initialize(object)
    require "java"
    @weakref = java.lang.ref.WeakReference.new(object)
  end

  def get
    return @weakref.get
  end

  def get!
    object = @weakref.get
    raise Wref::Recycled if object == nil
    return object
  end

  def alive?
    object = @weakref.get

    if object == nil
      return false
    else
      return true
    end
  end
end

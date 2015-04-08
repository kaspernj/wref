class Wref::Implementations::Ref
  def initialize(object)
    require "ref"
    @ref = ::Ref::WeakReference.new(object)
  end

  def get
    @ref.object
  end

  def get!
    object = @ref.object
    raise Wref::Recycled unless object
    return object
  end

  def alive?
    if @ref.object
      return true
    else
      return false
    end
  end
end

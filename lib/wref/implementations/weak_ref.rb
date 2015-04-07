class Wref::Implementations::WeakRef
  def initialize(object)
    require "weakref"
    @id = object.__id__
    @class_name = object.class.name.to_sym
    @weak_ref = ::WeakRef.new(object)
    ObjectSpace.define_finalizer(object, method(:destroy))
  end

  def get
    return nil unless @id

    begin
      object = @weak_ref.__getobj__
    rescue WeakRef::RefError
      destroy
      return nil
    end

    object_class_name = object.class.name

    if !object_class_name || @class_name != object_class_name.to_sym || @id != object.__id__
      destroy
      return nil
    end

    return object
  end

  def get!
    if object = get
      return object
    else
      raise Wref::Recycled
    end
  end

  def alive?
    if @weak_ref.weakref_alive? && get
      return true
    else
      return false
    end
  end

private

  def destroy(*args)
    @id = nil
    @class_name = nil
    @unique_id = nil
  end
end

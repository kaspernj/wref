class Wref::Implementations::IdClassUnique
  def initialize(object)
    @id = object.__id__
    @class_name = object.class.name.to_sym
    ObjectSpace.define_finalizer(object, method(:destroy))

    if object.respond_to?(:__wref_unique_id__)
      @unique_id = object.__wref_unique_id__
    end
  end

  def destroy(object_id)
    @id = nil
    @class_name = nil
    @unique_id = nil
  end

  def get!
    object = get
    raise ::Wref::Recycled unless object
    return object
  end

  def get
    return nil if !@class_name || !@id
    object = ObjectSpace._id2ref(@id)

    #Some times this class-name will be nil for some reason - knj
    object_class_name = object.class.name

    if !object_class_name || @class_name != object_class_name.to_sym || @id != object.__id__
      return nil
    end

    if @unique_id
      return nil if !object.respond_to?(:__wref_unique_id__) || object.__wref_unique_id__ != @unique_id
    end

    return object
  end

  def alive?
    if get
      return true
    else
      return false
    end
  end
end

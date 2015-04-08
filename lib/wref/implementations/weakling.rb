class Wref::Implementations::Weakling
  def initialize(object)
    require "weakling"
    @weak_ref = ::Weakling::WeakRef.new(object)
  end

  def get
    begin
      @weak_ref.get
    rescue ::WeakRef::RefError, ::Java::JavaLang::NullPointerException
      return nil
    end
  end

  def get!
    begin
      @weak_ref.get
    rescue ::WeakRef::RefError, ::Java::JavaLang::NullPointerException
      raise Wref::Recycled
    end
  end

  def alive?
    begin
      @weak_ref.get
      return true
    rescue ::WeakRef::RefError, ::Java::JavaLang::NullPointerException
      return false
    end
  end
end

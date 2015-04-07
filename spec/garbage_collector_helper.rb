module GarbageCollectorHelper
  def force_garbage_collect
    GC.enable

    sleep 0.1

    if RUBY_ENGINE == "jruby"
      GC.start
      java.lang.System.gc
      JRuby.gc
    else
      if RUBY_VERSION.start_with?("2")
        GC.start(full_mark: true, immediate_sweep: true)
      else
        GC.start
      end
    end

    sleep 0.1

    GC.disable
  end

  def force_garbage_collection
    force_garbage_collect

    10000.times do
      some_str = "#{Digest::MD5.hexdigest(Time.now.to_f.to_s)}".clone
      weak_ref = described_class.new(some_str)
      some_str = nil
    end

    force_garbage_collect
  end
end

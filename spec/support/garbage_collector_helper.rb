require "digest"

module GarbageCollectorHelper
  def force_garbage_collect
    GC.enable

    sleep 0.01

    if RUBY_ENGINE == "jruby"
      java.lang.System.gc
    elsif RUBY_VERSION.start_with?("2")
      GC.start(full_mark: true, immediate_sweep: true)
    else
      GC.start
    end

    sleep 0.01

    GC.disable
  end

  def force_garbage_collection
    force_garbage_collect

    10_000.times do
      some_str = User.new("User #{Digest::MD5.hexdigest(Time.now.to_f.to_s)}")
      weak_ref = described_class.new(some_str)
      some_str = nil
    end

    force_garbage_collect
  end
end

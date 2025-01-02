Gem::Specification.new do |s|
  s.name = "wref"
  s.version = File.read("VERSION")

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Kasper Stöckel"]
  s.description = "Lightweight weak reference and weak hash that works in 1.9 and JRuby."
  s.email = "kasper@diestoeckels.de"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = Dir["{include,lib}/**/*"] + ["Rakefile"]
  s.homepage = "http://github.com/kaspernj/wref"
  s.licenses = ["MIT"]
  s.summary = "Weak references and weak hash for Ruby"

  s.add_dependency "ref"
  s.add_dependency "weakling" if RUBY_PLATFORM == "java"
end

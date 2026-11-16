require "spec_helper"
require "yaml"

# The subject is the build config file at the repository root, not a class.
# rubocop:disable RSpec/DescribeClass
describe "tensorbuzz config" do
  def builds
    YAML.load_file(File.expand_path("../tensorbuzz.yml", __dir__)).fetch("builds")
  end

  def paths_for(build)
    build.fetch("paths")
  end

  it "declares paths on every build" do
    builds.each_value do |build|
      paths = paths_for(build)

      expect(paths).to be_an(Array)
      expect(paths).not_to be_empty

      paths.each do |pattern|
        # An unquoted `!` entry is a YAML tag, not a string, and parses as nil.
        expect(pattern).to be_a(String)
        expect(pattern).not_to be_empty
        expect(pattern.delete_prefix("!")).not_to be_empty
      end
    end
  end

  it "keeps every build fail-open with a catch-all rule so a new path can never be silently skipped" do
    builds.each_value do |build|
      expect(paths_for(build)).to include("**/*")
    end
  end

  it "excludes documentation and repository metadata from every build" do
    excluded = ["!*.md", "!LICENSE.txt", "!.document", "!.gitignore", "!.github/**"]

    builds.each_value do |build|
      expect(paths_for(build)).to include(*excluded)
    end
  end

  it "keeps lint configuration out of the rspec builds and inside the lint build" do
    lint_builds = builds.each_value.select { |build| build.fetch("script").include?("bundle exec rubocop") }
    rspec_builds = builds.each_value.reject { |build| build.fetch("script").include?("bundle exec rubocop") }

    expect(lint_builds.size).to eq(1)
    expect(rspec_builds.size).to eq(4)

    lint_builds.each do |build|
      expect(paths_for(build)).not_to include("!.rubocop.yml")
    end

    rspec_builds.each do |build|
      expect(paths_for(build)).to include("!.rubocop.yml", "!.rubocop_todo.yml")
    end
  end

  it "keeps every file bundler reads inside the paths of the build that runs it" do
    # Negating one of these would let a bump of it skip the only build that installs and checks it.
    always_required = ["!Gemfile", "!Gemfile.lock", "!VERSION", "!wref.gemspec", "!lib/**", "!spec/**"]

    builds.each_value do |build|
      expect(paths_for(build)).not_to include(*always_required)
    end
  end

  it "keeps tensorbuzz.yml as the only build config at the repository root" do
    # A legacy peak_flow.yml at the root is read ahead of this file and would replace every paths block.
    root = File.expand_path("..", __dir__)
    configs = Dir.glob("*.yml", base: root).select { |name| File.read(File.join(root, name)).include?("builds:") }

    expect(configs).to eq(["tensorbuzz.yml"])
  end
end
# rubocop:enable RSpec/DescribeClass

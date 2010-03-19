$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class FetchTest < Rip::Test
  def setup
    start_git_daemon
    start_gem_daemon
    super
  end

  test "fetch uncached git repository" do
    out = rip "fetch-git git://localhost/cijoe"
    target = "#{@ripdir}/.cache/cijoe-da109be2f8636efacba2984c933c2048"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/config")
  end

  test "fetch already cached git repository" do
    rip "fetch-git git://localhost/cijoe"

    out = rip "fetch-git git://localhost/cijoe"
    target = "#{@ripdir}/.cache/cijoe-da109be2f8636efacba2984c933c2048"
    assert_equal target, out.chomp
  end

  test "fetch with no repository" do
    out = rip "fetch-git"
    assert_equal "no git url given", out.chomp
  end

  test "fetch nonexistent repository" do
    out = rip "fetch-git /tmp/null.git"
    assert_equal "/tmp/null.git not found", out.chomp
  end

  test "fetch gem" do
    out = rip("fetch-gem repl 0.1.0").chomp
    target = "#{@ripdir}/.cache/repl-0.1.0.gem"
    assert_equal target, out
    assert File.exist?(target)
  end

  test "fetch nonexistent gem" do
    out = rip("fetch-gem foo 1.0").chomp
    assert_equal "foo 1.0 not found", out.chomp
  end

  test "fetch nonexistent gem version" do
    out = rip("fetch-gem repl 2.0").chomp
    assert_equal "repl 2.0 not found", out.chomp
  end

  test "fetch gem missing name" do
    out = rip("fetch-gem").chomp
    assert_equal "no gem name given", out.chomp
  end

  test "fetch gem missing version" do
    out = rip("fetch-gem repl").chomp
    assert_equal "no gem version given", out.chomp
  end
end

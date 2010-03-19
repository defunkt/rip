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

  test "fetch nonexistent repository" do
    out = rip "fetch-git /tmp/null.git"
    assert_equal "/tmp/null.git not found", out.chomp
  end
end

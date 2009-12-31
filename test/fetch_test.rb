$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class FetchTest < Rip::Test
  test "fetch git://" do
    out = rip "fetch git://localhost/repo"
    target = "#{@ripdir}/.cache/repo-f20b64796d6e86ec7654f683c3eea522"
    assert_equal target, out.chomp
    assert File.directory?(target)
  end

  test "fetch git@" do
  end

  test "fetch hg" do
  end

  test "fetch bzr" do
  end

  test "fetch http tar.gz" do
  end

  test "fetch http tar.bz" do
  end

  test "fetch svn" do
  end
end

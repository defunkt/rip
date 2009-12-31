$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class FetchTest < Rip::Test
  test "fetch git://" do
    out = rip "fetch git://localhost/cijoe"
    target = "#{@ripdir}/.cache/cijoe-da109be2f8636efacba2984c933c2048"
    assert_equal target, out.chomp
    assert File.directory?(target)
  end

  test "fetch git@"

  test "fetch hg"

  test "fetch bzr"

  test "fetch http tar.gz"

  test "fetch http tar.bz"

  test "fetch svn"

  test "fetch dependencies" do
    out = rip "fetch git://localhost/cijoe"
    out = rip "fetch-dependencies #{out.chomp}/deps.rip"
    puts out.inspect
    fetched = Dir["#{@ripdir}/.cache/*"].map do |f|
      File.basename(f).split('-', 2)[0]
    end
    assert_equal %w( cijoe rack sinatra tinder choice ), fetched
  end
end

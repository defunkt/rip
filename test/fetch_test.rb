$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class FetchTest < Rip::Test
  def setup
    start_git_daemon
    super
  end

  test "fetch git://" do
    out = rip "fetch git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-7aa689b246c733241b95105f1cd08845"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "fetch git:// with ref" do
    out = rip "fetch git://localhost/cijoe 28e583afc7c3153860e3b425fe4e4179f951835f"
    target = "#{@ripdir}/.packages/cijoe-414249968732aa0fc53b7f7ce94b84c8"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "fetch twice" do
    out = rip "fetch git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-7aa689b246c733241b95105f1cd08845"
    assert_equal target, out.chomp

    out = rip "fetch git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-7aa689b246c733241b95105f1cd08845"
    assert_equal target, out.chomp
  end

  test "fetch git@"

  test "fetch hg"

  test "fetch bzr"

  test "fetch http tar.gz"

  test "fetch http tar.bz"

  test "fetch svn"

  test "fetch dependencies" do
    out = rip "fetch git://localhost/cijoe"
    rip "fetch-dependencies #{out.chomp}/deps.rip"
    fetched = Dir["#{@ripdir}/.packages/*"].map do |f|
      File.basename(f).split('-', 2)[0]
    end
    assert_equal %w( cijoe rack sinatra tinder choice ).sort, fetched.sort
  end
end

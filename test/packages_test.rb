$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class PackagesTest < Rip::Test
  FIXTURES = File.expand_path(File.dirname(__FILE__) + "/fixtures")

  def setup
    start_git_daemon
    super
  end

  test "install cijoe.deps" do
    out = rip "install #{FIXTURES}/cijoe.deps"
    assert_exited_successfully out

    out = rip "packages"
    assert_equal "#{@ripdir}/.packages/cijoe-20053386165d0ace45a91cd03c9ea31f", out.chomp
  end
end

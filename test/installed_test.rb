$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class InstalledTest < Rip::Test
  FIXTURES = File.expand_path(File.dirname(__FILE__) + "/fixtures")

  def setup
    start_git_daemon
    super
  end

  test "install cijoe.deps" do
    out = rip "install #{FIXTURES}/cijoe.deps"
    assert_exited_successfully out

    out = rip "installed"
    assert_equal "git://localhost/cijoe e8a53aac256665563cf6bb27c04788ce758424ac", out.chomp
  end
end

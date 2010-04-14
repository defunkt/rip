$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class InstallTest < Rip::Test
  FIXTURES = File.expand_path(File.dirname(__FILE__) + "/fixtures")

  def setup
    start_git_daemon
    super
  end

  # test "install cijoe.deps" do
  #   out = rip "install #{FIXTURES}/cijoe.deps"
  #   assert_exited_successfully out
  #
  #   assert File.exist?("#{@ripdir}/base/bin/cijoe")
  #   assert File.exist?("#{@ripdir}/base/lib/cijoe.rb")
  #   assert File.exist?("#{@ripdir}/base/lib/cijoe/build.rb")
  # end

  test "records which files were installed" do
  end
end

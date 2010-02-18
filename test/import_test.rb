$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ImportTest < Rip::Test
  FIXTURES = File.expand_path(File.dirname(__FILE__) + "/fixtures")

  def setup
    super
    @cijoe = rip("fetch file://#{FIXTURES}/cijoe").chomp
  end

  def test_importing_files_into_ripdir
    out = rip "import", @cijoe
    assert_exited_successfully

    assert File.exist?("#{@ripdir}/base/bin/cijoe")
    assert File.exist?("#{@ripdir}/base/lib/cijoe.rb")
    assert File.exist?("#{@ripdir}/base/lib/cijoe/build.rb")

    files = out.split("\n")
    assert_equal "lib/cijoe/build.rb", files[0]
    assert_equal "lib/cijoe.rb", files[-2]
    assert_equal "bin/cijoe", files[-1]
  end
end

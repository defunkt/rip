require 'test/helper'

class InstallTest < Rip::Test
  def setup
    ENV['RIPRPG'] = '0'
    super
  end

  test "install cijoe-deps.rip" do
    out = rip "install #{fixture('cijoe-deps.rip')}"
    assert_exited_successfully out

    assert File.exist?("#{@ripdir}/base/bin/cijoe")
    assert File.exist?("#{@ripdir}/base/lib/cijoe.rb")
    assert File.exist?("#{@ripdir}/base/lib/cijoe/build.rb")
  end

  test "install repl gem" do
    out = rip "install repl"
    assert_exited_successfully out

    assert_equal "installed repl (0.1.0)", out.strip

    assert File.exist?("#{@ripdir}/base/bin/repl")
    assert File.exist?("#{@ripdir}/base/man/repl.1")
  end

  test "know about versions" do
    out = rip "install repl 0.100.0"
    assert_exited_with_error out
  end
end

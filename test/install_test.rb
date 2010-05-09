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

  test "pretend" do
    assert_equal <<packages, rip("install -p #{fixture('cijoe.deps')}")
git://localhost/tinder.git 29fb44ca9eb9a0c90f37286b92dafbffa5731b2e
git://localhost/sinatra.git e0ee682740d194e956a6936dcd89512944d891a3
git://localhost/rack.git 1.0
git://localhost/choice.git 8b12556493c86b07ff3efc0fa31f0981b5d1ff83
git://localhost/cijoe e8a53aac256665563cf6bb27c04788ce758424ac
packages
  end

  test "know about versions" do
    out = rip "install repl 0.100.0"
    assert_exited_with_error out
  end
end

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ImportTest < Rip::Test
  FIXTURES = File.expand_path(File.dirname(__FILE__) + "/fixtures")

  def setup
    super
    @cijoe = rip("package file://#{FIXTURES}/cijoe").chomp
  end

  test "import" do
    out = rip "package #{fixture(:cijoe)}"
    copied = rip "import #{out}"

    files = %w(
      lib/cijoe/build.rb
      lib/cijoe/campfire.rb
      lib/cijoe/commit.rb
      lib/cijoe/config.rb
      lib/cijoe/public/favicon.ico
      lib/cijoe/public/octocat.png
      lib/cijoe/public/screen.css
      lib/cijoe/server.rb
      lib/cijoe/version.rb
      lib/cijoe/views/template.erb
      lib/cijoe.rb
      bin/cijoe
    )

    assert_equal files.join("\n") + "\n", copied
  end

  test "importing files into ripdir" do
    out = rip("import", @cijoe)
    assert_exited_successfully out

    assert File.exist?("#{@ripdir}/base/bin/cijoe")
    assert File.exist?("#{@ripdir}/base/lib/cijoe.rb")
    assert File.exist?("#{@ripdir}/base/lib/cijoe/build.rb")

    files = out.split("\n")
    assert_equal "lib/cijoe/build.rb", files[0]
    assert_equal "lib/cijoe.rb", files[-2]
    assert_equal "bin/cijoe", files[-1]
  end
end

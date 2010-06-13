require 'helper'

class ImportTest < Rip::Test
  def setup
    super
    @cijoe = rip("package file://#{File.expand_path fixture(:cijoe)}").split("\n").last.chomp
  end

  test "import" do
    copied = rip "import #{@cijoe}"

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
      man/man1/cijoe.1
      man/man5/cijoe.conf.5
    )

    assert_equal files.join("\n") + "\n", copied
  end

  test "importing files into ripdir" do
    out = rip("import #{@cijoe}")
    assert_exited_successfully out

    assert File.exist?("#{@ripdir}/base/bin/cijoe")
    assert File.exist?("#{@ripdir}/base/lib/cijoe.rb")
    assert File.exist?("#{@ripdir}/base/lib/cijoe/build.rb")

    files = out.split("\n")
    assert_equal "lib/cijoe/build.rb", files[0]
    assert_equal "man/man1/cijoe.1", files[-2]
    assert_equal "lib/cijoe.rb", files[-4]
    assert_equal "bin/cijoe", files[-3]
  end
end

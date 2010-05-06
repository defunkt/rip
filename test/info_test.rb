require 'test/helper'

class InfoTest < Rip::Test
  test "info" do
    path = rip "package-gem repl 0.1.0"
    rip "import #{path}"
    write(path.chomp + '/deps.rip') { "ambition ~> 0.5.4" }

    assert_equal <<info, rip("info repl")
source: repl
version: 0.1.0
path: #{Rip.packages}/repl-21df4eaf07591b07688973bad525a215
bins:
- repl
manuals:
- repl.1
needs:
- ambition ~> 0.5.4
info
  end
end

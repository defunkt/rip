unless String < Enumerable
  class String
    alias_method :each, :each_line

    include Enumerable
  end
end

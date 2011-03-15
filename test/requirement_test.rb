require 'helper'

class TestVersion < Test::Unit::TestCase
  Version = Rip::Requirement::Version

  test "comparable" do
    assert Version.new('1.9.0').comparable?
    assert !Version.new('4fb27ff').comparable?
  end

  test "compare" do
    assert Version.new('1.9.0') < Version.new('1.10.0')
    assert Version.new('1.10.0') < Version.new('1.11.0')
    assert Version.new('1.0.0beta1') < Version.new('1.0.0beta2')
    assert Version.new('1.0.0beta2') < Version.new('1.0.0')
    assert Version.new('1.0.0rc') > Version.new('1.0.0beta3')

    assert Version.new('4fb27ff') == Version.new('4fb27ff')
    assert_raise(ArgumentError) { Version.new('4fb27ff') < Version.new('35515b7') }
  end

  test "spermy" do
    assert Version.new('1.9.0').send(:'~>', Version.new('1.9.0'))
    assert !Version.new('1.8.0').send(:'~>', Version.new('1.9.0'))
    assert !Version.new('2.0.0').send(:'~>', Version.new('1.9.0'))
    assert Version.new('1.9.1').send(:'~>', Version.new('1.9.0'))
    assert Version.new('1.9.9').send(:'~>', Version.new('1.9.0'))
    assert Version.new('1.9.10').send(:'~>', Version.new('1.9.0'))
    assert Version.new('1.9.2').send(:'~>', Version.new('1.9.2'))
    assert Version.new('1.9.3').send(:'~>', Version.new('1.9.2'))
    assert !Version.new('1.9.1').send(:'~>', Version.new('1.9.2'))

    assert_raise(ArgumentError) { Version.new('4fb27ff').send(:'~>', Version.new('4fb27ff')) }
  end

  test "eql" do
    assert Version.new('1.0').eql?(Version.new('1.0'))
    assert !Version.new('2.0').eql?(Version.new('1.0'))
    assert !Version.new('1.0.0').eql?(Version.new('1.0'))
    assert Version.new('4fb27ff').eql?(Version.new('4fb27ff'))
  end

  test "next" do
    assert_equal '1.8.0', Version.new('1.7.0').next.to_s
    assert_equal '1.8.0', Version.new('1.7.1').next.to_s
    assert_equal '1.8.0', Version.new('1.7.23').next.to_s
    assert_equal '1.9.0', Version.new('1.8.0').next.to_s
    assert_equal '1.10.0', Version.new('1.9.0').next.to_s
    assert_equal '1.9.0', Version.new('1.8.0beta3').next.to_s
    assert_equal nil, Version.new('4fb27ff').next
  end

  test "to_a" do
    assert_equal [1, 2], Version.new('1.2').to_a
    assert_equal [1, 2, 3], Version.new('1.2.3').to_a
    assert_equal [1, 11, 0], Version.new('1.11.0').to_a
    assert_equal [1, 0, 0, 'beta1'], Version.new('1.0.0beta1').to_a
    assert_equal ['4fb27ff'], Version.new('4fb27ff').to_a
  end

  test "to_s" do
    assert_equal '1.11.0', Version.new('1.11.0').to_s
    assert_equal '1.0.0beta1', Version.new('1.0.0beta1').to_s
    assert_equal '4fb27ff', Version.new('4fb27ff').to_s
  end
end

class TestRequirement < Test::Unit::TestCase
  Requirement = Rip::Requirement
  Version = Rip::Requirement::Version

  test "to_s" do
    assert_equal '1.0', Requirement.new('1.0').to_s
    assert_equal '1.0', Requirement.new('=1.0').to_s
    assert_equal '1.0', Requirement.new('= 1.0').to_s
    assert_equal '!=1.0', Requirement.new('!= 1.0').to_s
    assert_equal '>1.0', Requirement.new('> 1.0').to_s
    assert_equal '<1.0', Requirement.new('<1.0').to_s
    assert_equal '>=1.0', Requirement.new('>= 1.0').to_s
    assert_equal '<=1.0', Requirement.new('<=1.0').to_s
    assert_equal '~>1.0', Requirement.new('~>1.0').to_s

    assert_equal '>=0.0.1', Requirement.new("'>=0.0.1'").to_s
    assert_equal '>=0.0.1', Requirement.new('">=0.0.1"').to_s

    assert_equal '', Requirement.new('>=0').to_s
    assert_equal '', Requirement.new.to_s

    assert_equal '>=1.0,<2.0', Requirement.new('>=1.0,<2.0').to_s
    assert_equal '>=1.0,<2.0', Requirement.new('>=1.0, < 2.0').to_s
    assert_equal '>=1.0,<2.0', Requirement.new('>=1.0', '<2.0').to_s
  end

  test "any?" do
    assert Requirement.new('1.0').any?
    assert !Requirement.new('>=0').any?
    assert !Requirement.new.any?
  end

  test "include" do
    assert Requirement.new('=1.0').include?(Version.new('1.0'))
    assert !Requirement.new('=1.0').include?(Version.new('1.1'))

    assert Requirement.new('>=1.0').include?(Version.new('1.0'))
    assert Requirement.new('>=1.0').include?(Version.new('1.1'))
    assert Requirement.new('>=1.0').include?(Version.new('2.0'))
    assert !Requirement.new('>=1.0').include?(Version.new('0.9'))

    assert Requirement.new('<=2.0').include?(Version.new('1.0'))
    assert Requirement.new('<=2.0').include?(Version.new('1.9'))
    assert Requirement.new('<=2.0').include?(Version.new('2.0'))
    assert !Requirement.new('<=2.0').include?(Version.new('2.1'))

    assert Requirement.new('~>1.0').include?(Version.new('1.0'))
    assert Requirement.new('~>1.0').include?(Version.new('1.1'))
    assert Requirement.new('~>1.0').include?(Version.new('1.9'))
    assert !Requirement.new('~>1.0').include?(Version.new('0.9'))
    assert !Requirement.new('~>1.0').include?(Version.new('2.0'))

    assert Requirement.new('>=0').include?(Version.new('1.0'))
    assert Requirement.new.include?(Version.new('1.0'))
  end
end

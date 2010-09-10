require 'rubygems'
require 'test/unit'

# TODO: Remove this dependency by just copy-pasta'ing alias_method_chain.
require 'facets'

class Test::Unit::TestCase
  def self.teardown_badge_definitions
    if method_defined?(:teardown)
      alias_method_chain(:teardown, :remove_badge_definitions)
    else
      alias_method(:teardown, :teardown_with_remove_badge_definitions)
    end
  end

  def teardown_with_remove_badge_definitions
    # Clear out all of the rules that were created after every test.
    Trinket::Badges::Rules.constants.each do |rule|
      Trinket::Badges::Rules.class_eval { remove_const(rule) }
    end
  end
end

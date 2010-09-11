require 'test/unit'
require 'trinket/db'

Trinket::Database.connect(':memory:')

class Test::Unit::TestCase
  alias run_orig run
  def run(result, &block)
    Trinket::Database::DB.transaction do
      begin
        run_orig(result, &block)
      ensure
        raise(Sequel::Rollback)
      end
    end
  end

  def self.teardown_badge_definitions
    if method_defined?(:teardown)
      alias_method(:teardown_without_remove_badge_definitions, :teardown)
      alias_method(:teardown, :teardown_with_remove_badge_definitions)
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

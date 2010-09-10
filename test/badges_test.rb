require 'test/unit'

require 'test_helper'
require 'badges'

class BadgesTest < Test::Unit::TestCase
  teardown_badge_definitions

  def test_hasnt_achieved_must_have_achieved_constraint 
    Trinket::Badges.module_eval do
      badge :winnar_is_you do
        must_have_achieved :elected_president
      end
    end

    user = users(:sarah)
    Trinket::Badges.award_if_qualified(user, :winnar_is_you)

    assert !Badge.find_by_name("winnar_is_you").users.include?(user)
    assert user.badges.size == 0
  end

  def test_document_must_have_achieved_constraint
    Trinket::Badges.module_eval do
      badge :winnar_is_you do
        must_have_achieved :elected_president
      end
    end

    desc = Trinket::Badges::Rules::WinnarIsYou.requirements_in_words
    assert desc == "The user must have achieved the Elected President badge."
  end

  def test_document_must_have_achieved_times
    Trinket::Badges.module_eval do
      badge :winnar_is_you do
        must_have_achieved :elected_president, :times => 3
      end
    end

    desc = Trinket::Badges::Rules::WinnarIsYou.requirements_in_words
    assert desc == "The user must have achieved the Elected President badge 3 times."
  end

  def test_has_achieved_must_have_achieved_constraint
    Trinket::Badges.module_eval do
      badge :winnar_is_you do
        must_have_achieved :elected_president
      end
    end

    user = users(:sarah)
    user.badges << Badge.find_by_name("elected_president")
    Trinket::Badges.award_if_qualified(user, :winnar_is_you)

    assert Badge.find_by_name("winnar_is_you").users.include?(user)
    assert user.badges.size == 2
  end

  def test_can_only_be_awarded_once
    Trinket::Badges.module_eval do
      badge :winnar_is_you do
        is_one_time_only
      end
    end

    user = users(:sarah)
    user.badges << Badge.find_by_name("winnar_is_you")

    Trinket::Badges.award_if_qualified(user, :winnar_is_you)
    assert Badge.find_by_name("winnar_is_you").users.include?(user)
    assert user.badges.size == 1
  end

  def test_document_is_one_time_only
    Trinket::Badges.module_eval do
      badge :winnar_is_you do
        is_one_time_only
      end
    end

    desc = Trinket::Badges::Rules::WinnarIsYou.requirements_in_words
    assert desc == "Can only be awarded once."
  end

  def test_event_must_have_occurred
    Trinket::Badges.module_eval do
      badge :resolvinator do
        event_must_have_occurred :status, :value => "resolved"
      end
    end

    user = users(:sarah)
    Event.create!(:user => user, :name => "status", :value => "resolved")

    Trinket::Badges.award_if_qualified(user, :resolvinator)
    assert Badge.find_by_name("resolvinator").users.include?(user)
    assert user.badges.size == 1
  end

  def test_document_event_must_have_occurred
    Trinket::Badges.module_eval do
      badge :resolvinator do 
        event_must_have_occurred :status, :value => "resolved"
      end
    end

    desc = Trinket::Badges::Rules::Resolvinator.requirements_in_words
    assert desc == "The user must have performed the status event with the value resolved."
  end

  def test_event_must_have_occurred_value_incorrect
    Trinket::Badges.module_eval do 
      badge :resolvinator do
        event_must_have_occurred :status, :value => "resolved"
      end
    end

    user = users(:sarah)
    Event.create!(:user => user, :name => "status")

    Trinket::Badges.award_if_qualified(user, :resolvinator)
    assert !Badge.find_by_name("resolvinator").users.include?(user)
    assert user.badges.size == 0
  end

  def test_event_must_have_occurred_but_hasnt
    Trinket::Badges.module_eval do
      badge :resolvinator do
        event_must_have_occurred :status, :value => "resolved"
      end
    end

    user = users(:sarah)

    Trinket::Badges.award_if_qualified(user, :resolvinator)
    assert !Badge.find_by_name("resolvinator").users.include?(user)
    assert user.badges.size == 0
  end
end

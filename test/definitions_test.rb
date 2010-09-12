require 'helper'

require 'trinket/models/badge'
require 'trinket/models/player'
require 'trinket/models/event'
require 'trinket/Definitions'

class DefinitionsTest < Test::Unit::TestCase
  teardown_badge_definitions

  def setup
    Player.create(:name => "sarah")
    Badge.create(:name => "winnar_is_you")
    Badge.create(:name => "elected_president")
    Badge.create(:name => "resolvinator")
  end

  def test_create_duplicate_badge_definition_fails
    assert_raise Trinket::Definitions::DefinitionError do
      Trinket::Definitions.module_eval do
        badge :epic_lulz do
        end

        badge :epic_lulz do
        end
      end
    end
  end

  def test_hasnt_achieved_must_have_achieved_constraint 
    Trinket::Definitions.module_eval do
      badge :winnar_is_you do
        must_have_achieved :elected_president
      end
    end

    player = Player.first(:name => "sarah")
    Trinket::Definitions.award_if_qualified(player, :winnar_is_you)

    assert !Badge.first(:name => "winnar_is_you").players.include?(player)
    assert player.badges.size == 0
  end

  def test_document_must_have_achieved_constraint
    Trinket::Definitions.module_eval do
      badge :winnar_is_you do
        must_have_achieved :elected_president
      end
    end

    desc = Trinket::Definitions::Rules::WinnarIsYou.requirements_in_words
    assert desc == "The player must have achieved the Elected President badge."
  end

  def test_document_must_have_achieved_times
    Trinket::Definitions.module_eval do
      badge :winnar_is_you do
        must_have_achieved :elected_president, :times => 3
      end
    end

    desc = Trinket::Definitions::Rules::WinnarIsYou.requirements_in_words
    assert desc == "The player must have achieved the Elected President badge 3 times."
  end

  def test_has_achieved_must_have_achieved_constraint
    Trinket::Definitions.module_eval do
      badge :winnar_is_you do
        must_have_achieved :elected_president
      end
    end

    player = Player.first(:name => "sarah")
    player.add_badge(Badge.first(:name => "elected_president"))
    Trinket::Definitions.award_if_qualified(player, :winnar_is_you)

    assert player.badges.include?(Badge.first(:name => "winnar_is_you"))
    assert player.badges.size == 2
  end

  def test_can_only_be_awarded_once
    Trinket::Definitions.module_eval do
      badge :winnar_is_you do
        is_one_time_only
      end
    end

    player = Player.first(:name => "sarah")
    player.add_badge(Badge.first(:name => "winnar_is_you"))

    Trinket::Definitions.award_if_qualified(player, :winnar_is_you)
    assert Badge.first(:name => "winnar_is_you").players.include?(player)
    assert player.badges.size == 1
  end

  def test_document_is_one_time_only
    Trinket::Definitions.module_eval do
      badge :winnar_is_you do
        is_one_time_only
      end
    end

    desc = Trinket::Definitions::Rules::WinnarIsYou.requirements_in_words
    assert desc == "Can only be awarded once."
  end

  def test_event_must_have_occurred
    Trinket::Definitions.module_eval do
      badge :resolvinator do
        event_must_have_occurred "status:resolved"
      end
    end

    player = Player.first(:name => "sarah")
    Event.create(:player => player, :name => "status:resolved", :value => 1)

    Trinket::Definitions.award_if_qualified(player, :resolvinator)
    assert Badge.first(:name => "resolvinator").players.include?(player)
    assert player.badges.size == 1
  end

  def test_document_event_must_have_occurred
    Trinket::Definitions.module_eval do
      badge :resolvinator do 
        event_must_have_occurred :status
      end
    end

    desc = Trinket::Definitions::Rules::Resolvinator.requirements_in_words
    assert desc == "The player must have performed the status event."
  end

  def test_event_must_have_occurred_but_hasnt
    Trinket::Definitions.module_eval do
      badge :resolvinator do
        event_must_have_occurred :status
      end
    end

    player = Player.first(:name => "sarah")

    Trinket::Definitions.award_if_qualified(player, :resolvinator)
    assert !Badge.first(:name => "resolvinator").players.include?(player)
    assert player.badges.size == 0
  end

  def test_unicode_character_names_at_least_try_to_be_valid
    Trinket::Definitions.module_eval do
      badge "Sam? サームですか...?" do
        one_time_only
      end
    end
  end

  def test_crazy_name_fails_somewhat_gracefully
    assert_raise Trinket::Definitions::DefinitionError do
      Trinket::Definitions.module_eval do
        badge "サームですか...?" do
          one_time_only
        end
      end
    end
  end

  def test_badge_name_thats_not_in_the_db_creates_db_record
    assert Badge.first(:name => "Polarize the viewscreen!").nil?
    Trinket::Definitions.module_eval do
      badge "Polarize the viewscreen!" do
        event_must_have_occurred :subspace_anomoly
      end
    end
  end
end

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

    desc = Trinket::Definitions::Rules::Badge.requirements_in_words
    assert desc == "The player must have achieved the Elected President badge."
  end

  def test_document_must_have_achieved_times
    Trinket::Definitions.module_eval do
      badge :winnar_is_you do
        must_have_achieved :elected_president, :times => 3
      end
    end

    desc = Trinket::Definitions::Rules::Badge.requirements_in_words
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

    desc = Trinket::Definitions::Rules::Badge.requirements_in_words
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

    desc = Trinket::Definitions::Rules::Badge.requirements_in_words
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

  def test_name_definitions
    Trinket::Definitions.module_eval do
      badge "9/11 Changed Everything!" do
        one_time_only
      end

      badge "Anata no namae wa nan desuka?" do
        one_time_only
      end
    end

    assert Trinket::Definitions::Rules::NAMES.size == 2
    assert Trinket::Definitions::Rules.constants.size == 3 # includes the NAMES constant
    assert !Trinket::Definitions::Rules.const_get("Badge").nil?
    assert !Trinket::Definitions::Rules.const_get("Badge1").nil?
  end

  def test_crazy_name
    Trinket::Definitions.module_eval do
      badge "  サームですか...?" do
        one_time_only
      end
    end

    assert !Trinket::Definitions::Rules.const_get("Badge").nil?
    assert !Trinket::Definitions::Rules::NAMES["  サームですか...?"].nil?
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

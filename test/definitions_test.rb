require 'helper'

require 'trinket/models/badge'
require 'trinket/models/player'
require 'trinket/models/event'
require 'trinket/definitions'

require 'timecop'

require 'active_support/core_ext'
require 'active_support/duration'

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

  def test_within_invalid_doesnt_award
    Trinket::Definitions.module_eval do
      badge "Se habla español" do
        must_have_achieved "Spanish 101", :within => 1.day
      end
    end

    player = Player.first(:name => "sarah")
    Badge.create(:name => "Spanish 101")
    player.add_badge(Badge.first(:name => "Spanish 101"))
    
    Timecop.freeze(Date.today + 2.days) do
      Trinket::Definitions.award_if_qualified(player, "Se habla español")
      assert !Badge.first(:name => "Se habla español").players.include?(player)
      assert player.badges.size == 1 
    end
  end

  def test_within_valid_awards
    Trinket::Definitions.module_eval do
      badge "Panic" do
        must_have_achieved :elected_president, :within => 1.day
      end
    end

    sarah_palin = Player.first(:name => "sarah")
    sarah_palin.add_badge(Badge.first(:name => "elected_president"))

    Trinket::Definitions.award_if_qualified(sarah_palin, "Panic")
    assert Badge.first(:name => "Panic").players.include?(sarah_palin)
    assert sarah_palin.badges.size == 2
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
    assert desc == "The player must have achieved the elected_president badge."
  end

  def test_document_must_have_achieved_times
    Trinket::Definitions.module_eval do
      badge :winnar_is_you do
        must_have_achieved :elected_president, :times => 3
      end
    end

    desc = Trinket::Definitions::Rules::Badge.requirements_in_words
    assert desc == "The player must have achieved the elected_president badge 3 times."
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
        is_one_time_only
      end

      badge "Anata no namae wa nan desuka?" do
        is_one_time_only
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
        is_one_time_only
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

  def test_invalid_definition_raises_error
    assert_raise Trinket::Definitions::DefinitionError do
      Trinket::Definitions.module_eval do
        badge "<< Red Alert! >>" do
          not_a_method_whoooooosh! "test"
        end
      end
    end
  end

  def test_invalid_definition_doesnt_create_non_existant_badge
    assert_raise Trinket::Definitions::DefinitionError do
      Trinket::Definitions.module_eval do
        badge "<< Red Alert! >>" do
          not_a_method_whoooooosh! "test"
        end
      end
    end

    assert Badge.first(:name => "<< Red Alert! >>").nil?
  end

  def test_awarding_only_returns_badges_that_were_won
    Trinket::Definitions.module_eval do
      badge "Hacked the Gibson" do
        is_one_time_only
      end

      badge "Dr. No" do
        must_have_achieved "who cares"
      end
    end

    player = Player.first(:name => "sarah")
    badges_awarded = Trinket::Definitions.award(player)

    assert badges_awarded.include?("Hacked the Gibson")
    assert badges_awarded.size == 1 
  end

  def test_awarding_returns_badges
    Trinket::Definitions.module_eval do
      badge "Hacked the Gibson" do
        is_one_time_only
      end

      badge "Dr. No" do
        is_one_time_only
      end
    end

    player = Player.first(:name => "sarah")
    badges_awarded = Trinket::Definitions.award(player)

    assert badges_awarded.include?("Hacked the Gibson")
    assert badges_awarded.include?("Dr. No")
    assert badges_awarded.size == 2
  end
end

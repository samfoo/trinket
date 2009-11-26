require 'test_helper'
require 'lib/badges'

class BadgesTest < ActiveSupport::TestCase
  test "has acheived true" do
    module Trinket::Badges
      badge :winnar_is_you do
        must_have_acheived :elected_president
      end
    end

    user = users(:sarah)
    Trinket::Badges.run(user, :winnar_is_you)
    user.reload

    puts user.badges.inspect
  end
end

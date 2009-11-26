require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  test "can create" do
    Badge.create!(:name => "sam_rules", 
                  :display_name => "Sam Rules")
    b = Badge.find_by_name("sam_rules")

    assert_not_nil(b)
  end

  test "must have name" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Badge.create!(:display_name => "Sam Rules")
    end
  end

  test "must have display name" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Badge.create!(:name => "Sam Rules")
    end
  end

  test "unique name" do
    Badge.create!(:name => "apple_farmer",
                  :display_name => "Apple Farmer")

    assert_raises(ActiveRecord::RecordInvalid) do
      Badge.create!(:name => "apple_farmer",
                    :display_name => "Apple Farmer")
    end
  end
end

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "can create" do
    User.create!(:email => "sam@ifdown.net", 
                 :password => "test",
                 :password_confirmation => "test",
                 :first_name => "Sam",
                 :last_name => "Gibson")

    u = User.find_by_email("sam@ifdown.net")

    assert_not_nil(u)
  end

  test "must have first name" do
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(:email => "sam@ifdown.net", :last_name => "Gibson")
    end
  end

  test "must have last name" do
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(:email => "sam@ifdown.net", :first_name => "Sam")
    end
  end

  test "unique email" do
    User.create!(:email => "sam@ifdown.net", 
                 :password => "test",
                 :password_confirmation => "test",
                 :first_name => "Sam",
                 :last_name => "Gibson")

    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(:email => "sam@ifdown.net", 
                   :password => "test",
                   :password_confirmation => "test",
                   :first_name => "Sam",
                   :last_name => "Gibson")
    end
  end

  test "has acheived negative" do
    assert !users(:sarah).has_acheived?(:elected_president)
  end

  test "the apocolypse" do
    users(:sarah).badges << badges(:elected_president)
    users(:sarah).reload

    assert users(:sarah).badges.size == 1
    assert users(:sarah).has_acheived?(:elected_president)

    # TODO: Panic.
  end

  test "multiple times" do
    3.times { users(:sarah).badges << badges(:elected_president) }
    users(:sarah).reload

    assert users(:sarah).badges.size == 3
    assert users(:sarah).has_acheived?(:elected_president, :times => 3)
  end

  test "time threshold" do
    b = badges(:elected_president)
    b.created_at = 2.days.ago
    users(:sarah).badges << b

    assert !users(:sarah).has_acheived?(:elected_president, :within => 1.hour)
    assert users(:sarah).has_acheived?(:elected_president, :within => 3.days)
  end

  test "time threshold with multiples" do
    b = badges(:elected_president)
    b.created_at = 2.days.ago
    users(:sarah).badges << b

    b.created_at = 1.day.ago
    2.times { users(:sarah).badges << b }

    assert !users(:sarah).has_acheived?(:elected_president, :within => 1.hour)
    assert users(:sarah).has_acheived?(:elected_president, :times => 3, :within => 3.days)
    assert users(:sarah).has_acheived?(:elected_president, :times => 2, :within => 25.hours)
  end
end

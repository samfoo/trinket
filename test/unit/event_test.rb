require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "can create" do
    e = Event.create!(:name => "status",
                      :user => users(:sarah))
    assert_not_nil(e)
  end

  test "invalid name fails" do
    assert_raises(ActiveRecord::RecordInvalid) do 
      Event.create!(:name => "i am the very model of a modern major general",
                    :user => users(:sarah))
    end
  end

  test "requires a user" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Event.create!(:name => "status")
    end
  end

  test "email is an acceptable substitute for user" do
    e = Event.create!(:name => "status",
                      :email => users(:sarah).email)
    assert_not_nil(e)
    assert e.user_id == users(:sarah).id
  end
end

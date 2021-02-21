require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_can_create
    user = User.new(:email => 'johndoenew@example.org', :login => 'user3', :password => 'ABBAACDC', :password_confirmation => 'ABBAACDC')

    assert user.valid?

    assert user.save
  end
end

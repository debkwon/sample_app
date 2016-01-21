require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
  	@user = User.new(name: "Example User", email: "user@example.com", 
  		password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do 
  	assert @user.valid?
  end

  test "name should be present" do
  	@user.name = ""
  	assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = "   "
  	assert_not @user.valid?
  end

  test "name shouldn't be too long" do
  	@user.name = "a" * 51
  	assert_not @user.valid?
  end

  test "email shouldn't be too long" do 
  	@user.email = "a" * 244 + "@example.com"
  	assert_not @user.valid?
  end

  test "email validation should accept valid email addresses" do
  	valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foobar.org 
  						first.last@foo.jp blah+blah@meow.cn]
  	valid_addresses.each do |valid_address|
  		@user.email = valid_address
  		assert @user.valid?, "#{valid_address.inspect} should be valid"
  	end
  end

  test "email validation should reject invalid email addresses" do
  	invalid_addresses = %w[user@example,com user_at_foo.org user.blah@user. 
  						beep@boop_bop.com  meow@meow+meow.com]
  	invalid_addresses.each do |invalid_address|
  		@user.email = invalid_address
  		assert_not @user.valid?, "#{invalid_address.inspect} should be rejected as invalid"
  	end
  	end

  	test "email addresses should be unique" do 
  		duplicate_user = @user.dup
  		@user.save #saving our user from setup so this test checks against the record in the db
  		assert_not duplicate_user.valid?
  	end

  	test "password should be nonblank" do
  		@user.password = @user.password_confirmation = " " * 6
  		assert_not @user.valid?
  	end

  	test "password should have a minimum length" do
  		@user.password = @user.password_confirmation = "a" * 5
  		assert_not @user.valid?
  	end

end

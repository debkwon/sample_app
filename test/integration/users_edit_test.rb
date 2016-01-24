require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:michael)
	end

	test "unsuccessful edit" do
		log_in_as(@user) #log_in_as method defined in test_helper. we need to be logged in test sessions
		get edit_user_path(@user)
		assert_template 'users/edit'
		patch user_path(@user), user: { name: "",
										email: "foo@invalid",
										password: "foo",
										password: "bar"	}
		assert_template 'users/edit'
	end

	test "successful edit" do
		log_in_as(@user) #log_in_as method defined in test_helper
	    get edit_user_path(@user)
	    assert_template 'users/edit'
	    name  = "Foo Bar"
	    email = "foo@bar.com"
	    patch user_path(@user), user: { name:  name,
	                                    email: email,
	                                    password:              "",
	                                    password_confirmation: "" }
	    assert_not flash.empty?
	    assert_redirected_to @user
	    @user.reload #reload the user’s values from the database and confirm that they were successfully updated
	    assert_equal name,  @user.name
	    assert_equal email, @user.email
 	end

 	test "successful edit with friendly forwarding" do
	    get edit_user_path(@user)
	    log_in_as(@user)
	    assert_redirected_to edit_user_path(@user)
	    name  = "Foo Bar"
	    email = "foo@bar.com"
	    patch user_path(@user), user: { name:  name,
	                                    email: email,
	                                    password:              "",
	                                    password_confirmation: "" }
	    assert_not flash.empty?
	    assert_redirected_to @user
	    @user.reload
	    assert_equal name,  @user.name
	    assert_equal email, @user.email
  end

end

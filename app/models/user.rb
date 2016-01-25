class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
	has_many :following, through: :active_relationships, source: :followed
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :followers, through: :passive_relationships
  
  attr_accessor :remember_token, :activation_token, :reset_token
  
	before_save :downcase_email
  before_create :create_activation_digest

	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX },
			  uniqueness: { case_sensitive: false }
	has_secure_password #this is a Rails method, previously there was a double validation with this method for empty pw and the one below
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true # has_secure_password includes a separate presence validation that specifically catches nil passwords

	def User.digest(string) #returns hash digest of given string
    	cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    	BCrypt::Password.create(string, cost: cost)
  	end

	def User.new_token
  	SecureRandom.urlsafe_base64 #returns random token
	end

	def remember
		self.remember_token = User.new_token #takes the returned token for this specific user object and stores it in its remember_token attr
  	update_attribute(:remember_digest, User.digest(remember_token)) #we update our database column, remember_digest, by setting it equal to the digestified token we just set as remmeber_token
	end

	def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

	 def forget
  	update_attribute(:remember_digest, nil)
	 end

   def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
   end

   def send_activation_email
    UserMailer.account_activation(self).deliver_now
   end

   def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago #resent_sent_at earlier than two hours ago, returns true of so
  end

  def feed
   following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
    #The question mark ensures that id is properly escaped 
    # before being included in the underlying SQL query, thereby 
    # avoiding a serious security hole called SQL injection. The id 
    # attribute here is just an integer (i.e., self.id, the unique ID 
    # of the user), so there is no danger of SQL injection in this case, 
    # but always escaping variables injected into SQL statements is a good 
    # habit to cultivate.
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

   ####################################
   private
   ####################################
   def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
   end

   def downcase_email
    self.email = email.downcase
  end



end

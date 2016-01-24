class User < ActiveRecord::Base
	attr_accessor :remember_token
  
	before_save { self.email = email.downcase }
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

  	def authenticated?(remember_token)
  		return false if remember_digest.nil?
    	BCrypt::Password.new(remember_digest).is_password?(remember_token)
  	end

  	 def forget
    	update_attribute(:remember_digest, nil)
  	 end

end

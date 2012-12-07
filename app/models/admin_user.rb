require 'digest/sha1'

class AdminUser < ActiveRecord::Base
  has_and_belongs_to_many :pages
  has_many :section_edits
  has_many :sections, :through => :section_edits
  
  attr_accessor :password # creates an accessor for the password, but password isn't saved
  
  # If this is used elsewhere, put it in config/initializers/constants.rb
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
	
	# standard validation methods
#   validates_presence_of :first_name
#   validates_length_of :first_name, :maximum => 25
#   validates_presence_of :last_name
#   validates_length_of :last_name, :maximum => 50
#   validates_presence_of :username
#   validates_length_of :username, :within => 8..25
#   validates_uniqueness_of :username
#   validates_presence_of :email
#   validates_length_of :email, :maximum => 100
#   validates_format_of :email, :with => EMAIL_REGEX
#   validates_confirmation_of :email # creates virtual attribute email_confirmation

  # sexy validations
  validates :first_name, :presence => true, :length => { :maximum => 25 }
  validates :last_name, :presence => true, :length => { :maximum => 50 }
  validates :username, :presence => true, :length => { :within => 8..25 }, :uniqueness => true
  validates :email, :presence => true, :length => { :maximum => 100 }, :format => EMAIL_REGEX, :confirmation => true

  # only on creation, so other attributes of this user can be changed
  validates_length_of :password, :within => 8..25, :on => :create

  # callbacks
  before_save :create_hashed_password
  after_save :clear_password
  
  scope :named, lambda {|first,last| where(:first_name => first, :last_name => last)}
  attr_protected :hashed_password, :salt
  
  def self.make_salt(username="")
  	Digest::SHA1.hexdigest("Use #{username} with #{Time.now} to make salt")
  end
  
  def self.hash_with_salt(password="", salt="")
  	Digest::SHA1.hexdigest("Put #{salt} on the #{password}")
  end
  
  def self.authenticate(username="", password="")
  	# 1. query for username
  	user = AdminUser.where(:username => username).first
  	# could also use find_by_username
  	
  	return false if user == nil
	# 2 if found, encrypt and compare passwords
	hashed_password = AdminUser.hash_with_salt(password,user.salt)
	return false if hashed_password != user.hashed_password
	return user
  end
  
  private #everything below here callable only by class
  
  def create_hashed_password
  	# whenever :password has a value hashing is needed
  	unless password.blank?
  		# always use self when assigning values
  		self.salt = AdminUser.make_salt(username) if salt.blank? # make the salt if we don't have it
  		self.hashed_password = AdminUser.hash_with_salt(password, salt)
  	end
  end

  def clear_password
  	self.password = nil
  end
  
  
end
require 'digest'
class User < ActiveRecord::Base
  attr_accessor :password
  validates_uniqueness_of :email
  validates_length_of :email, :within => 5..50
  validates_format_of :email, :with => /\A[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}\z/i
  validates_confirmation_of :password

  has_one :profile, :dependent => :destroy
  has_many :articles, -> { order('published_at DESC, title ASC') },
           :dependent => :nullify
  has_many :replies, :through => :articles, :source => :comments

  before_save :encrypt_new_password

  def self.authenticate(email, password)
    user = find_by_email(email)
    return user if user && user.authenticate?(password)
  end

  def authenticate?(password)
    self.hashed_password == encrypt(password)
  end

  protected
  def encrypt_new_password
    return if password.blank?
    self.hashed_password = encrypt(password)
  end

  def password_required?
    hashed_password.blank? || password.present?
  end

  def encrypt(string)
    Digest::SHA1.hexdigest(string)
  end
end

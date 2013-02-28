# Class to capsulate all database functions
#
require "redis"
require "digest/md5"
require "bcrypt"

class RedisDB
  USERS_SET = "users"
  USERS_INFO = [:username, :password, :email]

  def initialize
    @r = Redis.new
  end

  # create a new user
  def create_user(username, password, email)
    @r.multi do
      # add the user to the users set
      @r.sadd "#{USERS_SET}", username

      # then create the user information 
      @r.set "users:#{username}:username", username
      @r.set "users:#{username}:password", create_pass(password)
      @r.set "users:#{username}:email", email
    end
  end

  # delete all user information
  def delete_user(username)
    @r.multi do
      # delete from the user set
      @r.srem "#{USERS_SET}", username

      # then delete all user's information
      USERS_INFO.each do |attr|
        @r.del "users:#{username}:#{attr}"
      end
    end
  end

  # check if a user already is stored in the database
  def user_exists?(username)
    @r.sismember "#{USERS_SET}", username 
  end

  # check login credentials
  def valid_user?(username, password)
    user_exists?(username) && valid_password?(username, password)
  end

  def valid_password?(username, password)
    pass(@r.get("users:#{username}:password")) == password
  end

  private
  def create_pass(password)
    BCrypt::Password.create password
  end

  def pass(password)
    BCrypt::Password.new(password)
  end
end

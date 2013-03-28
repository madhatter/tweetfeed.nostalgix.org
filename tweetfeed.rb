require 'sinatra'
require 'haml'
require 'pony'
require_relative 'redisdb'

configure do
  enable :sessions
  set :session_secret, "for_security"
end

get "/" do
  @session = session[:tfeed]
  haml :index
end

get "/about" do
  haml :about
end

get "/signup" do
  haml :signup
end

post "/signup" do
  username = params[:username]
  password = params[:password]
  mail = params[:mail]

  #Pony.mail(:to => 'arvid.warnecke@gmail.com', :from => "#{mail}", :subject => "art inquiry from #{username}", :body => "Trallera")

  redis = RedisDB.new
  unless  redis.user_exists? username
    redis.create_user username, password, mail
  else
    puts "User already exists. So what now?"
  end

  haml :signup
end

get "/login" do
  haml :login
end

post "/login" do
  username = params[:username]
  password = params[:password]

  redis = RedisDB.new
  if redis.user_exists? username
    if redis.valid_user? username, password
      # create session, set cookies and what not
      puts "You would have been logged in."
      session[:tfeed] = Time.now
      redirect "/"
    else
      puts "Wrong password."
    end
  else
    puts "Not a valid username."
  end
end

get "/logout" do
  session.clear
  redirect "/"
end

def send_registration_mail mail
  options = load_mail_settings
  Pony.mail({
    :to => mail,
    :via => :smtp,
    :via_options => options,
    :subject => titel + " - " + price.to_s + " Euro",
    :body => link
  })
end

def load_mail_settings
  #TODO: get user, password and domain from redis
  options = {
      :address              => 'smtp.gmail.com',
      :port                 => '587',
      :enable_starttls_auto => true,
      #:user_name            => configuration['mail_user'],
      :user_name            => 'tweetfeed@nostalgix.org',
      #:password             => configuration['mail_password'],
      :password             => 'password',
      :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
    } 
end

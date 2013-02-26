require 'sinatra'
require 'haml'
require_relative 'redisdb'

get "/" do
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
    else
      puts "Wrong password."
    end
  else
    puts "Not a valid username."
  end
end


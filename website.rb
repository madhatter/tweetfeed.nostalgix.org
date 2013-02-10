require 'sinatra'
require 'haml'

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
  mail = params[:mail]

  #Pony.mail(:to => 'arvid.warnecke@gmail.com', :from => "#{mail}", :subject => "art inquiry from #{username}", :body => "Trallera")
  puts "Username: #{username}, Email: #{mail}."

  haml :signup
end

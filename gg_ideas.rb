require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'nokogiri'
require 'open-uri'

class MyApp < Sinatra::Base
  set :static, true
  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/' do
    "you need to provide a /idea/[number] on the URL, sorry"
  end

  get '/idea/:argument' do

    @myidea = "#{params[:argument]}"
    @userlist = Array.new
    idea = "http://community.giffgaff.com/restapi/vc/messages/id/#{params[:argument]}/kudos/givers?page_size=100"
    doc = Nokogiri::XML(open(idea))
    response = doc.css("response")
    response.css("users").children.each do |user|
      username = user.css("login")[0]
      @userlist << username.content if username
    end

    erb :list_users
  end

end




require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'nokogiri'
require 'open-uri'

class GiffGaffIdeas < Sinatra::Base

configure do
  set :static, true
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :server, 'thin'
end

  get '/' do
    # currently we don't do anything if you don't provide an argument
    "you need to provide a /idea/[number] on the URL, sorry - or go to the <a href='http://community.giffgaff.com/t5/Submit-Great-giffgaff-Ideas/idb-p/ideas_01'>Ideas Forum</a>"
  end

  get '/idea/:argument' do

    # the number of the idea is in the URL
    @myidea = "#{params[:argument]}"

    # get the url to the message containing the idea so we can link to it later
    rawurl = "http://community.giffgaff.com/restapi/vc/messages/id/#{params[:argument]}/web_page_url"
    doc2 = Nokogiri::XML(open(rawurl))
    @ideaurl = doc2.xpath("//string/text()")

    # now find out how many kudos that idea has received
    rawkudos = "http://community.giffgaff.com/restapi/vc/messages/id/#{params[:argument]}/kudos/count"
    doc1 = Nokogiri::XML(open(rawkudos))
    response1 = doc1.css("response")
    number_of_kudos = response1.css("value")[0]
    @kudosnumber = number_of_kudos

    # set up a list to hold the usernames
    @userlist = Array.new

    # call the API and read the usernames into the list
    # maxes out at 1000 users without paging
    # docs are here https://community.lithium.com/t5/Community-API/bd-p/developers-rest-api?leaf-id=Message.kudos.givers#Message.kudos.givers
    idea = "http://community.giffgaff.com/restapi/vc/messages/id/#{params[:argument]}/kudos/givers?page_size=1000"
    doc = Nokogiri::XML(open(idea))
    response = doc.css("response")
    response.css("users").children.each do |user|
      username = user.css("login")[0]
      @userlist << username.content if username
    end

    # finally, render the result page
    erb :list_users
  end

end

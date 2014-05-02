require 'sinatra/base'
require 'securerandom'

module HappinessPoll
  class App < Sinatra::Base
    
    get "/assets/js/application.js" do
      content_type :js
      @uuid = request.params['name'] || SecureRandom.uuid
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"application.js"
    end

    get "/" do
      erb :"index-noname.html"
    end

    get '/:name' do
      @uuid = params[:name]
      erb :"index.html"
    end

  end
end

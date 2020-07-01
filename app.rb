require 'sinatra/base'
require 'securerandom'
require 'airbrake'

Airbrake.configure do |c|
  c.project_id = ENV['AIRBRAKE_PROJECT_ID']
  c.project_key = ENV['AIRBRAKE_PROJECT_KEY']
  c.logger.level = Logger::DEBUG
end

module HappinessPoll
  class App < Sinatra::Base
    use Airbrake::Rack::Middleware
    
    get "/assets/js/application.js" do
      content_type :js
      @uuid = request.params['name'] || SecureRandom.uuid
      @scheme = ["production", "staging"].include?(ENV['RACK_ENV']) ? "wss://" : "ws://"
      @ab_project_id = ENV['AIRBRAKE_PROJECT_ID']
      @ab_project_key = ENV['AIRBRAKE_PROJECT_KEY']
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

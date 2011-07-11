require 'sinatra'
require 'slim'

get '/' do
  slim :index
end

get '/inbox/:name' do
  "Hello #{params[:name]}!"
end

get '/question/:name' do
end

get '/subscriptions/:name' do
end
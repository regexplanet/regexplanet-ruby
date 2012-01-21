require 'sinatra'
require "sinatra/json"

get '/status.json' do
	json( {
		:status => true,
		:message => "OK",
		:RUBY_PLATFORM => RUBY_PLATFORM,
		:RUBY_PATCHLEVEL => RUBY_PATCHLEVEL,
		:RUBY_VERSION => RUBY_VERSION,
	} )
end

get '/test.json' do
	"Coming soon"
end

get '/' do
	"Hello world!"
end

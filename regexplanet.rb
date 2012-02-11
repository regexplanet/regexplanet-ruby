require 'sinatra'
require "sinatra/jsonp"

configure do
	mime_type :ico, 'image/x-icon'
	set :static_cache_control, [:public, {:max_age => 604800 } ]
end

error do
	jsonp( {
		:success => false,
		:message => env['sinatra.error'].message,
		:error_name => env['sinatra.error'].name,
	} )
end

get '/status.json' do
	jsonp( {
		:success => true,
		:message => "OK",
		"request.host" => request.host,
		"request.port" => request.port,
		:RUBY_DESCRIPTION => RUBY_DESCRIPTION,
		:RUBY_PLATFORM => RUBY_PLATFORM,
		:RUBY_PATCHLEVEL => RUBY_PATCHLEVEL,
		:RUBY_RELEASE_DATE => RUBY_RELEASE_DATE,
		:RUBY_VERSION => RUBY_VERSION,
	} )
end

get '/test.json' do
	output = ""

	output << '<table class="table table-bordered table-striped" style="width:auto;">\n'

	output << '\t<tr>\n'
	output << '\t\t<td>Regular Expression</td>\n'
	output << '\t\t<td>'
	output << h(params[:regex])
	output << '</td>\n'
	output << '\t</tr>\n'

	output << '\t<tr>\n'
	output << '\t\t<td>Replacement</td>\n'
	output << '\t\t<td>'
	output << h(params[:replacement])
	output << '</td>\n'
	output << '\t</tr>\n'

	output << '</table>\n'

	jsonp( {
		:success => true,
		:message => "OK",
		:html => output,
	} )
end

get '/' do
	redirect 'http://www.regexplanet.com/advanced/ruby/index.html'
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

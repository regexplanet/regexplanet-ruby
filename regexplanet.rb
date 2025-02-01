#!/usr/bin/env ruby

require 'cgi'
require 'sinatra'
require "sinatra/jsonp"
require 'sinatra/reloader'
require 'time'

configure do
	mime_type :ico, 'image/x-icon'
	mime_type :svg, 'image/svg+xml'
	set :static_cache_control, [:public, {:max_age => 604800 } ]
	set :bind, '0.0.0.0'
	set :host_authorization, { permitted_hosts: [] }
	#set :protection, :except => [:frame_options ]
	#disable :protection
end

error do
	jsonp( {
		:success => false,
		:message => env['sinatra.error'].message,
		:error_name => env['sinatra.error'].name,
	} )
end


def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

get_or_post '/status.json' do
	headers \
		'Access-Control-Allow-Origin' => '*',
		'Access-Control-Allow-Methods' => 'POST, GET',
		'Access-Control-Max-Age' => '604800'

	jsonp( {
		:success => true,
		:message => "OK",
		:commit => ENV['COMMIT'],
		:lastmod => ENV['LASTMOD'],
		:tech => "Ruby #{RUBY_VERSION}",
		:timestamp => Time.now.utc.iso8601,
		:version => RUBY_VERSION,
		:detail => RUBY_DESCRIPTION,
		"request.host" => request.host,
		"request.port" => request.port,
		:RUBY_DESCRIPTION => RUBY_DESCRIPTION,
		:RUBY_PLATFORM => RUBY_PLATFORM,
		:RUBY_PATCHLEVEL => RUBY_PATCHLEVEL,
		:RUBY_RELEASE_DATE => RUBY_RELEASE_DATE,
		:RUBY_VERSION => RUBY_VERSION,
		"$," => $,,
	} )
end

options '/test.json' do
	content_type :text
	headers \
		'Access-Control-Allow-Origin' => '*',
		'Access-Control-Allow-Methods' => 'POST, GET',
		'Access-Control-Max-Age' => '604800'
	body 'Yes, CORS is allowed!'
end

get_or_post '/test.json' do
	content_type :text
	headers \
		'Access-Control-Allow-Origin' => '*',
		'Access-Control-Allow-Methods' => 'POST, GET',
		'Access-Control-Max-Age' => '604800'

	output = ""

	str_regex = params[:regex]

	if str_regex.nil? || str_regex.length() == 0
		return jsonp(
			:success => false,
			:message => "No regular expression to test"
			)
	end

	if request.request_method == "get"
		form_data = request.query_string
	else
		form_data = request.env["rack.input"].read
	end

	output << "<table class=\"table table-bordered table-striped\" style=\"width:auto;\">\n"

	output << "\t<tr>\n"
	output << "\t\t<td>Regular Expression</td>\n"
	output << "\t\t<td>"
	output << h(str_regex)
	output << "</td>\n"
	output << "\t</tr>\n"

	output << "\t<tr>\n"
	output << "\t\t<td>Replacement</td>\n"
	output << "\t\t<td>"
	output << h(params[:replacement])
	output << "</td>\n"

	options = 0
	str_options = request_params_multi(form_data)[:option]
	if str_options
		if str_options.include?("comment")
			options += Regexp::EXTENDED
		end
		if str_options.include?("dotall")
			options += Regexp::MULTILINE
		end
		if str_options.include?("ignorecase")
			options += Regexp::IGNORECASE
		end
	end

	begin
		regex = Regexp.new(str_regex, options)
	rescue Exception => e
		output << "\t<tr>\n"
		output << "\t\t<td>Exception</td>\n"
		output << "\t\t<td>"
		output << e.message
		output << "</td>\n"
		output << "\t</tr>\n"
		output << "</table>\n"
		return jsonp(
			:success => false,
			:message => "Regexp.new Exception: " + e.message,
			:html => output
			)
	end
	# when ruby 1.9
	#if Regexp.try_convert(str_regex)
	#	output << "\t<tr>\n"
	#	output << "\t\t<td>Error</td>\n"
	#	output << "\t\t<td>try_convert failed</td>\n"
	#	output << "\t</tr>\n"
	#	output << "</table>"
	#	jsonp( {
	#		:success => false,
	#		:message => "Regexp::try_convert failed!",
	#		:html => output,
	#	} )
	#end

	if regex
		output << "\t<tr>\n"
		output << "\t\t<td>Options</td>\n"
		output << "\t\t<td>"
		output << regex.options.to_s
		output << "</td>\n"
		output << "\t</tr>\n"

		if regex.options != 0
			output << "\t<tr>\n"
			output << "\t\t<td>Options as constants</td>\n"
			output << "\t\t<td>"
			if (regex.options & Regexp::IGNORECASE) != 0
				output << "Regexp::IGNORECASE "
			end
			if (regex.options & Regexp::EXTENDED) != 0
				output << "Regexp::EXTENDED "
			end
			if (regex.options & Regexp::MULTILINE) != 0
				output << "Regexp::MULTILINE "
			end
			#if (regex.options & Regexp::FIXEDENCODING) != 0
			#	output << "Regexp::FIXEDENCODING "
			#end
			#if (regex.options & Regexp::NOENCODING) != 0
			#	output << "Regexp::NOENCODING "
			#end
			output << "</td>\n"
			output << "\t</tr>\n"
		end

		# when ruby1.9
		#names = regex.names
		#if names
		#	output << "\t<tr>\n"
		#	output << "\t\t<td>Named captures (names)</td>\n"
		#	output << "\t\t<td>"
		#	output << h(names.to_s)
		#	output << "</td>\n"
		#end

	end

	output << "</table>\n"

	output << "<table class=\"table table-bordered table-striped\">\n"

	output << "\t<tr>\n"
	output << "\t\t<th style=\"text-align:center;\">Test</th>\n"
	output << "\t\t<th>Input</th>"
	output << "\t\t<th>=~</th>"
	output << "\t\t<th>match()</th>"
	output << "\t</tr>\n"

	inputs = request_params_multi(form_data)["input"]

	if not inputs
		output << "\t<tr>\n"
		output << "\t\t<td colspan=\"2\"><i>"
		#output << "(no inputs)"
		output << h(request.query_string)
		output << "</i></td>\n"
		output << "\t</tr>\n"
	else
		for index in 0..inputs.length - 1
			input = inputs[index]

			if input == nil or input.length == 0
				next
			end

			output << "\t<tr>\n"
			output << "\t\t<td style=\"text-align:center;\">"
			output << (index + 1).to_s
			output << "</td>\n"
			output << "\t\t<td>"
			output << h(input)
			output << "</td>\n"

			output << "\t\t<td>"
			eq = regex =~ input
			if eq
				output << h(eq.to_s)
			else
				output << "<i>nil</i>"
			end
			output << "</td>\n"

			md = regex.match(input)
			if md == nil
				output << "\t\t<td><i>"
				output << "nil"
				output << "</i></td>\n"
				output << "\t</tr>\n"
			else
				first = true
				while md != nil
					if first
						first = false
					else
						output << "\t<tr>\n"
						output << "\t\t<td colspan=\"3\" style=\"text-align:right;\">regex.match(matchdata.post_match)</td>"
					end
					output << "\t\t<td>"
					for mdindex in 0..md.size-1
						output << "["
						output << mdindex.to_s
						output << "]: "
						output << h(md[mdindex])
						output << "<br/>"
					end
					output << "</td>\n"
					output << "\t</tr>\n"
					md = regex.match(md.post_match)
				end
			end
		end
	end

	output << "</table>\n"

	jsonp( {
		:success => true,
		:message => "OK",
		:html => output,
	} )
end

get '/' do
	headers \
		'Content-Type' => 'text/plain'
	"Running Ruby " + RUBY_VERSION + " on " + RUBY_PLATFORM
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

# I hope I missed something & there is a built-in way to do this...
def request_params_multi(qs)
	params = {}
	qs.split('&').each do |pair|
	  kv = pair.split('=').map{|v| CGI.unescape(v)}
	  params.merge!({kv[0]=> kv.length > 1 ? kv[1] : nil }) {|key, o, n| o.is_a?(Array) ? o << n : [o,n]}
	end
	params
end


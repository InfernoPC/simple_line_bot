class WelcomeController < ApplicationController

	protect_from_forgery with: :null_session
	def webhook

		client = Line::Bot::Client.new {|config|
			config.channel_secret = ENV['line_channel_secret']
			config.channel_token = ENV['line_channel_token']
		}

		reply_token = params['events'].first['replyToken']

		response_message = case params['events'].first['message']['text']
		when 'pb'
			puts 'get pb!'
			{
				type: 'postback',
				label: 'postback',
				data: 'action=postback',
				displayText: 'try postback'
			}
		when 'msg'
			puts 'get msg!'
			{
				type: 'message',
				label: 'reply',
				text: 'message sent!'
			}
		when 'uri'
			puts 'get uri!'
			{
				type: 'uri',
				label: 'google.com',
				uri: 'http://www.google.com/'
			}
		when 'dt'
			puts 'get dt!'
			{
				type: 'datetimepicker',
				label: 'select date',
				date: 'storeId=12345', # ???
				mode: 'datetime',
			}
		when 'cam'
			puts 'get cam!'
			{
				type: 'camera',
				label: 'Camera'
			}
		when 'loc'
			puts 'get loc!'
			{
				type: 'location',
				label: 'Location'
			}
		when '?'
			{
				type: 'text',
				text: 'pb, msg, uri, dt, cam, loc'
			}
		else
			{	
				type: 'text',
				text: params['events'].first['message']['text']
			}
		end


		client.reply_message reply_token, response_message

		head :ok
	end
end

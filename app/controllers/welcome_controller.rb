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
			reply_pb
		when 'msg'
			reply_msg
		when 'uri'
			reply_uri
		when 'dt'
			reply_dt
		when 'cam'
			reply_cam
		when 'loc'
			reply_loc
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

	private
	def reply_pb
		{
			type: 'postback',
			label: 'postback',
			data: 'action=postback',
			displayText: 'try postback'
		}
	end
	def reply_msg
		{
			type: 'message',
			label: 'reply',
			text: 'message sent!'
		}
	end
	def reply_uri
		{
			type: 'uri',
			label: 'google.com',
			uri: 'http://www.google.com/'
		}
	end
	def reply_dt
		{
			type: 'datetimepicker',
			label: 'select date',
			date: 'storeId=12345', # ???
			mode: 'datetime',
		}
	end
	def reply_cam
		{
			type: 'camera',
			label: 'Camera'
		}
	end
	def reply_loc
		{
			type: 'location',
			label: 'Location'
		}
	end

end

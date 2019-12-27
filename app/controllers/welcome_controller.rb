class WelcomeController < ApplicationController

	protect_from_forgery with: :null_session
	def webhook

		client = Line::Bot::Client.new {|config|
			config.channel_secret = ENV['line_channel_secret']
			config.channel_token = ENV['line_channel_token']
		}

		reply_token = params['events'].first['replyToken']

		response_message = case params['events'].first['message']['text']
		when 'menu'
			{
				type: 'text',
				text: 'Select one.',
				quickReply: {
					items: [
						{	type: 'action', action: { type: 'message', label: 'sushi', text: 'sushi' }},
						{	type: 'action', action: { type: 'message', label: 'tempura', text: 'tempura' }},
						{	type: 'action', action: { type: 'location', label: 'send location' }}
					]
				}
			}
		when '?'
			{
				type: 'text',
				text: 'menu'
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

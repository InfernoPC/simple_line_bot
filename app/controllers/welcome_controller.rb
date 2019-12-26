class WelcomeController < ApplicationController

	protect_from_forgery with: :null_session
	def webhook

		client = Line::Bot::Client.new {|config|
			config.channel_secret = ENV['line_channel_secret']
			config.channel_token = ENV['line_channel_token']
		}

		reply_token = params['events'].first['replyToken']

		response_message = case params['events'].first['message']['type']
			when 'text'	
				{ 
					type: 'text',
					text: params['events'].first['message']['text']
				}
			when 'sticker'
				{
					type: 'sticker',
	        id: "11149181584287",
	        stickerId: "1691913",
	        packageId: "1040299",
	        stickerResourceType: "STATIC"
				}
		end


		client.reply_message reply_token, response_message

		head :ok
	end
end

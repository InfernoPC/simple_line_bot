class WelcomeController < ApplicationController

	DRAW_MESSAGE = ['哈哈～平手！', '好阿，學我出一樣的。']
	WIN_MESSAGE = ['我贏啦～哼哼！', '歐耶～我贏了！']
	LOSE_MESSAGE = ['你贏了，呿。', '好阿都給你贏就好啦']

	protect_from_forgery with: :null_session
	def webhook

		client = Line::Bot::Client.new {|config|
			config.channel_secret = ENV['line_channel_secret']
			config.channel_token = ENV['line_channel_token']
		}

		reply_token = params['events'].first['replyToken']
		
		first_event = params['events'].first

		if first_event['type'] == 'postback'
			postback_params = first_event['postback']['data'].split('&').inject({}) do |h, s|
				e = s.split('=')
				h[e.first] = e.last
				h
			end
			download_image postback_params['message_id']
		elsif first_event['type'] == 'message'
			response_message = case first_event['message']['type']
												 when 'text'
													 reply_text
												 when 'image'
													 ask_download_image
												 end
		end

		client.reply_message reply_token, response_message unless response_message.nil?

		head :ok
	end

	private
	def ask_download_image
		{
			type: 'text',
			text: 'Backup this image?',
			quickReply: {
				items: [
					{	type: 'action', 
						action: {type: 'postback', label: 'Yes', data: "message_id=#{params['events'].first['message']['id']}", text: 'yes'}
					},
					{ type: 'action',
						action: {type: 'message', label: 'No', text: 'no'}
					}
				]
			}
		}
	end
	def download_image message_id
		download_command = "curl -o #{download_filename} -X GET #{download_image_url(message_id)} -H 'Authorization: Bearer #{ENV['line_channel_token']}'"
		puts download_command
		exec download_command
	end

	def download_image_url message_id
		"https://api-data.line.me/v2/bot/message/#{message_id}/content"
	end

	def download_filename
		"tmp/#{Time.now.strftime '%Y-%m-%d_%H-%M-%S'}"
	end

	def reply_text
		
		case params['events'].first['message']['text']
		when 'menu'
			{
				type: 'text',
				text: 'Select one.',
				quickReply: {
					items: [
						{	type: 'action', action: { type: 'message', label: '猜拳', text: '猜拳' }},
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
		when '猜拳'
			{
				type: 'text',
				text: '剪刀，石頭…',
				quickReply: {
					items: [
						{type: 'action', action: {
							type: 'message', label: '剪刀', text: '剪刀'
						}}, 
						{type: 'action', action: {
							type: 'message', label: '石頭', text: '石頭'
						}}, 
						{type: 'action', action: {
							type: 'message', label: '布', text: '布'
						}} 
					]
				}
			}
		when '剪刀', '石頭', '布'
			user = params['events'].first['message']['text']
			ai = ['剪刀', '石頭', '布'].sample
			if user == ai
				{
					type: 'text', 
					text: "#{ai}！ #{DRAW_MESSAGE.sample}"
				}
			elsif (user == '剪刀' and ai == '石頭') or (user == '石頭' and ai == '布') or (user == '布' and ai == '剪刀')
				{
					type: 'text',
					text: "#{ai}！ #{WIN_MESSAGE.sample}"
				}
			else
				{
					type: 'text',
					text: "#{ai}！ #{LOSE_MESSAGE.sample}"
				}
			end
		else
			{	
				type: 'text',
				text: params['events'].first['message']['text']
			}
		end
	end
end

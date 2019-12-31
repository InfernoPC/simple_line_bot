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

		response_message = case params['events'].first['message']['type']
											 when 'text'
												 reply_text
											 when 'image'
												 ask_download_image
											 when 'postback'
												 download_image
											 end

		client.reply_message reply_token, response_message

		head :ok
	end

	private
	def ask_download_image
		
		{
			type: 'template',
			altText: 'ask download image',
			template: {
				type: 'confirm',
				text: 'Download this image?',
				actions: [
					{type: 'postback', label: 'Yes', data: "message_id=#{params['events'].first['message']['id']}", text: 'yes'},
					{type: 'message', label: 'No', text: 'no'}
				]
			}
		}

	end
	def download_image

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

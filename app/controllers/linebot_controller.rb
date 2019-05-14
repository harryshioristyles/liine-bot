class LinebotController < ApplicationController

  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    # ここでlineに送られたイベントを検出している
    # messageのtext: に指定すると、返信する文字を決定することができる
    # event.message['text']で送られたメッセージを取得することができる
    events.each { |event|
      case event #case文　caseの値がwhenと一致する時にwhenの中の文章が実行される(switch文みたいなもの)
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
        	if event.message['text'] == "ありがとう"
        		message = {
	            type: 'text',
	            text: "どういたちまちて"
	          }
	          client.reply_message(event['replyToken'], message)
        	else
	          message = {
	            type: 'text',
	            text: event.message['text']
	          }
	          client.reply_message(event['replyToken'], message)
        	end

        end
      end
    }

    head :ok
  end
end

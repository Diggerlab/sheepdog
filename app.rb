require 'sinatra'
require 'digest/sha1'
require 'nokogiri'
require 'mysql2'
require 'dotenv'
Dotenv.load

WECHAT_TOKEN = ENV['WECHAT_TOKEN']
GAME_ID = 1

get '/' do  
	str = [WECHAT_TOKEN, params[:timestamp], params[:nonce]].sort.join('')
	if params[:signature] == Digest::SHA1.hexdigest(str)
		params[:echostr] 
	else
		status 401
		"signature check failed"
	end
end

post '/' do
	xml = Nokogiri::XML(request.body.read)
	client = xml.xpath("//xml/FromUserName")
	server = xml.xpath("//xml/ToUserName")
	content = xml.xpath("//xml/Content").text
	@from_user = server.text
	@to_user = client.text

	case content
	when 'kpi'
		connection = Mysql2::Client.new host: ENV['DW_HOST'],
                                username: ENV['DW_USER'],
                                password: ENV['DW_PWD'],
                                database: ENV['DW_DB']
    results = connection.query "select dim_date_id as D, total_users as PU, today_logins as DAU, today_users as DNU, concat(cast(one_days_retention_rate*100 as char(4)), '%') as 1DR, concat(cast(three_days_retention_rate*100 as char(4)), '%') as 3DR, concat(cast(seven_days_retention_rate*100 as char(4)), '%') as 7DR, concat(cast(fourteen_days_retention_rate*100 as char(4)), '%') as 14DR, concat(cast(thirty_days_retention_rate*100 as char(4)), '%') as 30DR from fact_active_users where dim_game_id=#{GAME_ID} order by dim_date_id desc limit 3"
    @content = ''
  	results.each do |record|
  		@content += record.to_s.gsub("\"", "").gsub("{", "").gsub("}", "").gsub("=>", ": ").gsub(",", ",")
  		@content += "\n\n"
  	end
	
	end
	erb :create
end
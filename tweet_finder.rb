require 'rubygems'
require 'oauth'
require 'json'
require 'pry'
require 'date'

def tweets_that_rated(tweets)
  rater_tweet = {}
  tweets.each do |tweet|
    if tweet['text'][/(\s\d{1,2})\/10/]
      rater_tweet[:text] = tweet['text'].gsub(/\n/,'<br>')
      rater_tweet[:id] = tweet['id']
      rater_tweet[:name] = tweet['user']['name']
      rater_tweet[:screen_name] = tweet['user']['screen_name']
      rater_tweet[:created_at] = tweet['created_at']
      break
    end
  end
  rater_tweet
end

def get_many_tweets(search_term)
  many_tweets = []
  tweet_ids = []
  max_id = 999999999999999999
  baseurl = "https://api.twitter.com"
  path    = "/1.1/search/tweets.json"
  search = URI.encode_www_form("q" => search_term)

  consumer_key = OAuth::Consumer.new("")
  access_token = OAuth::Token.new("","")

  5.times do
    search_params = URI.encode_www_form("count" => 100,"lang"=>'en',"max_id"=>max_id)
    address = URI("#{baseurl}#{path}?#{search}&#{search_params}")
    request = Net::HTTP::Get.new address.request_uri

    http             = Net::HTTP.new address.host, address.port
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request.oauth! http, consumer_key, access_token
    http.start
    response = http.request request

    tweets = nil
    if response.code == '200' then
      data = JSON.parse(response.body)['statuses']
      break if data.empty?
      tweet_ids << tweets_that_rated(data)
      tweets = data.map{|i| i['text'] }
      max_id = data[-1]["id"] - 1
      many_tweets += tweets
    else
      break
    end
  end
  [many_tweets,tweet_ids]
end

def get_ratings_from_tweets(search_str)
  search_term = ' /10 '+ search_str+' -RT'
  tweet_data = get_many_tweets(search_term)
  tweets = tweet_data[0]
  ratings = tweets.map{|t| /(\s\d{1,2})\/10/.match(t)}.compact!
  average_rating = ratings.map!{|r| r[1].to_i}.reduce(0.0,:+)/ratings.length
  rating_str = "Average rating for #{search_str} based on #{ratings.length} recent tweets: #{average_rating}"
  [rating_str,tweet_data[1]]
end


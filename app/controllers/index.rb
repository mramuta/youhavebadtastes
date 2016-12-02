require_relative '../../tweet_finder'
get '/' do
  tweet_data = get_ratings_from_tweets('doctor_strange')
  @rating_str = tweet_data[0]
  @tweets = tweet_data[1]
  erb :index
end

class Company
  include Mongoid::Document
  include Mongoid::Slug
  
  field :name, type: String
  slug  :name, :history => true
  field :stock_ticker_symbol, type: String
  field :last_tweet_id
  
  has_many :documents
  has_many :clusters
  validates_presence_of :name
  validates_presence_of :stock_ticker_symbol
  
  
  def tweet_client
    Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV["twitter_api_key"]
      config.consumer_secret = ENV["twitter_api_secret"]
    end
  end
  
  def keywords
    name
  end
  
  def query_params(options = {})
    {result_type: "recent", language: "ru", since_id: last_tweet_id}.merge options
  end
  
  def yahoo_ticker_symbol
    stock_ticker_symbol + ".me"
  end
  
  def load_finance_data
    data = YahooFinance.quotes([yahoo_ticker_symbol], [:bid]).first
    clusters.find_or_create_by(created_at: Date.today).insert_quote(data.bid.to_f)
  end
  
  def load_tweets(status)
    tweets = tweet_client.search(keywords, query_params).take(100)
    tweets.each do |tweet|
      if documents.where(tweet: tweet.text.dup).ne(sentiment_in: nil).exists?
        prev_tweet = documents.where(tweet: tweet.text.dup).ne(sentiment_in: nil).last
        document = documents.create(tweet: tweet.text.dup, status: status, created_at: tweet.created_at, number_of_followers: tweet.user.followers_count, number_of_friends: tweet.user.friends_count, user_verified: (tweet.user.verified? ? 1 : 0), sentiment_id: prev_tweet.sentiment_id)
      else
        document = documents.create(tweet: tweet.text.dup, status: status, created_at: tweet.created_at, number_of_followers: tweet.user.followers_count, number_of_friends: tweet.user.friends_count, user_verified: (tweet.user.verified? ? 1 : 0))
      end
    end
    set(last_tweet_id: tweets.last.id)
  end
  
  def clear_data
    documents.delete_all
    clusters.delete_all
  end
  
  def self.clear_data
    Company.all.each { |company| company.clear_data }
    Word.delete_all
  end
    
    
  def self.load_data(status=:real)
    Company.all.each do |company|
      company.load_finance_data if Time.now.hour < 19 && Time.now.hour > 10
      company.load_tweets(status)
    end
  end
   
end

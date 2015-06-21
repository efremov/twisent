class Company
  include Mongoid::Document
  include Mongoid::Slug
  
  field :name, type: String
  slug  :name, :history => true
  field :stock_ticker_symbol, type: String
  field :last_tweet_id
  field :correlation_coefs, type: Hash, default: {}
  
  has_many :documents
  has_many :clusters
  has_one :accuracy_test
  validates_presence_of :name
  validates_presence_of :stock_ticker_symbol
  


  def tweet_client
    Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV["twitter_api_key"]
      config.consumer_secret = ENV["twitter_api_secret"]
    end
  end
  
  def quiry(granularity = nil, period = nil)
    Twisent::Aggregate.new(self, granularity, period)
  end

  def api_quiry(metrics, granularity = nil, period=nil)
    data = []
    quiry(granularity, period).data_set.each_pair do |date, values| 
      if metrics.class == Array
        metrics.each_with_index do |metric, index|
          (data[index] ||= []) << [transform(date), values[metric.to_sym].round(3)] if values[metric.to_sym].present?
        end
      else
        data << [transform(date), values[metrics.to_sym].round(3)]
      end
    end
    return data.to_json
  end


  def find_lags(granularity = "day", metrics = ["iok", "growth"])
    data = quiry_time_series(granularity, metrics)
    correlation = []

      
    (0..[9, data[0].count].min).each do |lag|
      correlation << find_correlation(data, lag)
    end
    

    correlation_coefs[granularity] = correlation
    set(correlation_coefs: correlation_coefs)
    
    return correlation

  end

  def correlation_chart
    series = [{name: I18n.t(:daily), data: []},{name: I18n.t(:hourly), data: []},{name: I18n.t(:minutly), data: []}]
    correlation_coefs.each do |granularity, correlation|
      case granularity
      when "day"
        series[0][:data] = correlation
      when "hour"
        series[1][:data] = correlation
      when "minute"
        series[2][:data] = correlation
      end
    end
    return series.to_json
  end


  def quiry_time_series(granularity = "day", metrics = ["iok", "growth"],  period=nil)
    data = []
    quiry(granularity).data_set.each_pair do |date, values|
      metrics.each_with_index do |metric, index|
        (data[index] ||= []) << values[metric.to_sym].round(4)
      end
    end
    return data
  end


  def find_correlation(data, lag = 0)
    return nil if data[0].length - lag < 3
    begin
      correlation = R.converse("cor(a,b)", a: data[0].first(data[0].count - lag), b: data[1].last(data[0].count - lag)) 
      correlation.class == Bignum ? 0 : correlation.round(3)
    rescue
      nil
    end
  end

  def current_cluster
    clusters.find_or_create_by(created_at: Date.today)
  end
  
  def transform(moment)
    moment.to_time.to_i * 1000
  end
  
  def keywords
    name
  end
  
  def number_of_tweets(date = Date.today)
    documents.between(created_at: date.at_beginning_of_day..date.at_end_of_day).count
  end
  
  def company_sentiment_index(date = Date.today)
    clusters.find_or_create_by(created_at: date).iok
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

  def load_historian_data
    data = YahooFinance.historical_quotes([yahoo_ticker_symbol], { start_date: Time::now-2.weeks, end_date: Time::now })
    data.each do |financial_data|
      cluster = clusters.find_or_create_by(created_at: financial_data.trade_date.to_date)
      cluster.set(close: financial_data[:close].to_f)
      cluster.set(open: financial_data[:open].to_f)
    end
  end

  URI_REGEX = %r"((?:(?:[^ :/?#]+):)(?://(?:[^ /?#]*))(?:[^ ?#]*)(?:\?(?:[^ #]*))?(?:#(?:[^ ]*))?)"
  def remove_url(tweet)
    tweet.gsub!(URI_REGEX, '')
  end

  def load_historical_tweets
    status = :train
    (2..9).each do |i|
      params = {:result_type=>"recent", :language=>"ru", "until"=> Date.today - (i-1).days, "since"=> Date.today - i.days}
      tweets = tweet_client.search(keywords, params).take(30)
      tweets.each do |tweet|
        tweet_message = remove_url(tweet.text.dup)
        if documents.where(tweet: tweet_message).ne(sentiment_in: nil).exists?
          prev_tweet = documents.where(tweet: tweet_message).ne(sentiment_in: nil).last
          document = documents.create(tweet: tweet_message, status: status, created_at: tweet.created_at, number_of_followers: tweet.user.followers_count, number_of_friends: tweet.user.friends_count, user_verified: (tweet.user.verified? ? 1 : 0), sentiment_id: prev_tweet.sentiment_id)
        else
          document = documents.create(tweet: tweet_message, status: status, created_at: tweet.created_at, number_of_followers: tweet.user.followers_count, number_of_friends: tweet.user.friends_count, user_verified: (tweet.user.verified? ? 1 : 0))
        end
      end      
    end
  end
  
  def load_tweets(status)
    tweets = tweet_client.search(keywords, query_params).take(60)
    tweets.each do |tweet|
      tweet_message = remove_url(tweet.text.dup)
      if documents.where(tweet: tweet_message).ne(sentiment_in: nil).exists?
        prev_tweet = documents.where(tweet: tweet_message).ne(sentiment_in: nil).last
        document = documents.create(tweet: tweet_message, status: status, created_at: tweet.created_at, number_of_followers: tweet.user.followers_count, number_of_friends: tweet.user.friends_count, user_verified: (tweet.user.verified? ? 1 : 0), sentiment_id: prev_tweet.sentiment_id)
      else
        document = documents.create(tweet: tweet_message, status: status, created_at: tweet.created_at, number_of_followers: tweet.user.followers_count, number_of_friends: tweet.user.friends_count, user_verified: (tweet.user.verified? ? 1 : 0))
      end
    end
    set(last_tweet_id: tweets.last.id)
  end
  
  def clear_data
    documents.delete_all
    clusters.delete_all
    set(correlation_coefs: {}, last_tweet_id: nil)
    accuracy_test.delete if accuracy_test.present?
  end
  
  def self.clear_data
    Company.all.each { |company| company.clear_data }
    Word.delete_all
  end
    
    
  def self.load_data(status=:real)
    Company.all.each do |company|
      company.load_finance_data if Time.now.hour < 18 && Time.now.hour > 10
      company.load_tweets(status)
    end
  end

  def self.build_model
    Company.all.each do |company|
      ["day", "hour", "minute"].each do |granularity|
        company.find_lags(granularity)
      end
    end
  end
   
end

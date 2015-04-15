class Cluster
  include Mongoid::Document
  belongs_to :company
  field :created_at, type: Date, default: Date.today
  field :hourly, type: Hash, default: {}
  field :minutly, type: Hash, default: {}
  field :open, type: Float
  field :positive, type: Integer, default: 0
  field :negative, type: Integer, default: 0
  field :neutral, type: Integer, default: 0
  
  DEFAULT_VALUES = {"price" => 0, "positive" => 0, "negative" => 0, "neutral" => 0}
  
  before_create :default_data
  
  def insert_quote(stock_info, moment = Time.now)
    inc("minutly.#{moment.hour * 60 + moment.min}.price" => stock_info) unless minutly[(moment.hour * 60 + moment.min).to_s]["price"] > 0
    inc("hourly.#{moment.hour}.price" => stock_info) unless hourly[moment.hour.to_s]["price"] > 0
  end
  
  def insert_sentiment(sentiment, moment = Time.now)
    inc("hourly.#{moment.hour}.#{sentiment}" => 1, "minutly.#{moment.hour * 60 + moment.min}.#{sentiment}" => 1, "#{sentiment}" => 1)
  end
    
  def default_data

    (10..18).each do |hour|
      self.hourly[hour.to_s] = DEFAULT_VALUES
      (0..59).each do |minute|
        self.minutly[(hour*60 + minute).to_s] = DEFAULT_VALUES
      end
    end
    self.open = YahooFinance.quotes([company.yahoo_ticker_symbol], [:open]).first.open.to_f  
  end
  
  def get_price moment, granularity
    if granularity == :hour
      return hourly[moment.hour.to_s]["price"]
    else
      (0..10).each do |counter|
        price = minutly[((moment - counter.minutes).hour * 60 + (moment - counter.minutes).min).to_s]["price"]
        return price if price
      end
    end 
    return nil
  end
  
    
end
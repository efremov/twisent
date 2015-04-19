class Cluster
  include Mongoid::Document
  belongs_to :company
  field :created_at, type: Date, default: Date.today
  field :hourly, type: Hash, default: {}
  field :minutly, type: Hash, default: {}
  field :open, type: Float
  field :close, type: Float
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
  
  def financial_date
    YahooFinance.quotes([company.yahoo_ticker_symbol], [:open, :previous_close]).first
  end
  
  def previous
    company.clusters.where(created_at: created_at.yesterday).exists? ? company.clusters.find_by(created_at: created_at.yesterday) : nil
  end
  
  def iok(pos = positive, neg = negative, neu = neutral)
    pos+neg+neu > 0 ? (pos - neg).fdiv(pos+neg+neu) : 0
  end
  
  def growth
    if close
      open > 0 ? close.fdiv(open) - 1 : 0
    else  
      1139.downto(600).each do |minute|
        return (minutly[minute.to_s]["price"].fdiv(open) - 1).round(3) if minutly[minute.to_s]["price"] > 0
      end
    end
  end
    
  def default_data
    (10..18).each do |hour|
      self.hourly[hour.to_s] = DEFAULT_VALUES
      (0..59).each {|minute| self.minutly[(hour*60 + minute).to_s] = DEFAULT_VALUES }
    end
    
    self.open = financial_date.open.to_f
    previous.close = financial_date.previous_close.to_f if previous
  end
    
end
class Document
  include Mongoid::Document
  field :corpus, type: Array, default: []
  field :tweet, type: String
  field :status, type: String, default: "real_data"
  field :number_of_favorites, type: Integer, default: 0
  field :number_of_shares, type: Integer, default: 0
  field :number_of_followers, type: Integer, default: 0
  field :number_of_friends, type: Integer, default: 0
  field :user_verified, type: Integer, default: 0
  
  validates_presence_of :tweet
  
  belongs_to :sentiment
  belongs_to :company
  
  before_create :create_corpus
  after_create :classify
  after_update :add_words_to_mega_vocabulary
  
  def training?
    status == "training"
  end
  
  def self.training_set
    where(status: "training")
  end
  
  def real_data?
    status == "real_data"
  end
  
  def self.real_data
    where(status: "real_data")
  end
  
  def test?
    status == "test"
  end
  
  def self.testing_set
    where(status: "test")
  end
  
  def create_corpus
    tokenize
    #indexed text and query terms must have the same format
    normalize
  end
  
  def tokenize
    
    self.corpus = tweet.split(" ")
    
    #reduce all letters to lowercase
    self.corpus.map! {|word| word.downcase}
    
    #remove all numbers and symbols
    self.corpus.map! {|word| word.gsub(/[^а-я]/, '')}
  end
  
  def normalize
    #reduce terms to their stems in information retrieval
    stemming
    
    # очень не хороший человек => очень не_хороший человек
    reverse_negations
    
    #clips all the word counts in each document at 1
    remove_duplicates
  end
  
  def reverse_negations
    (1..self.corpus.count).each do |counter|
      if self.corpus[counter - 1] == "не"
        self.corpus[counter] = "не_" + self.corpus[counter]
        self.corpus.delete_at(counter - 1)
      end
    end
  end
  
  def stemming
    self.corpus = Lingua.stemmer(corpus, :language => "ru" )
  end
  
  def remove_duplicates
    self.corpus = self.corpus.uniq.reject{|w| w.length < 2 }
  end
  
  def self.compute_likelihood(sentiment, word)
   return 0 if Word.count == 0
   (sentiment.words.where(name: word).sum(:frequency)+ 1).fdiv(sentiment.words.sum(:frequency) + Word.pluck(:name).uniq.count)
  end
  
  def naive_bayes_classifier
    probabilies = {}
    Sentiment.all.each do |sentiment|
      if sentiment.words.count > 0
        probability = Math.log(sentiment.compute_prior) 
        corpus.each do |word|
          probability += Math.log(Document.compute_likelihood(sentiment, word))
        end
        probabilies[sentiment.id] = probability 
      end
    end
    return probabilies
  end
  
  def most_probable_sentiment
    return Sentiment.find(naive_bayes_classifier.max_by{|k,v| v}[0]) unless naive_bayes_classifier.empty?
    false
  end
  
  def classify
    # calculate probabilities of different classes
    set(sentiment_id: most_probable_sentiment.id) unless training? 
    
    #put all words in related mega document
    add_words_to_mega_vocabulary if sentiment.present?
  end
  
  def add_words_to_mega_vocabulary
    corpus.each do |word|
      sentiment.words.find_or_create_by(name: word).inc(frequency: 1)
    end
  end
  
  
end

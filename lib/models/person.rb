class Person
  include Mongoid::Document
  
  field :name
  field :follows, :type => Array
  field :reviews, :type => Hash
  field :scores, :type => Hash
  field :recommendations, :type => Hash
  
  def self.update_scores
    Database.db[pearson_results.name].find.each do |result|
      Person.find(result["_id"]).update_attributes(:scores => result["value"])
    end
  end
  
  def self.pearson_results
    @pearson_results ||= Pearson.run
  end
  
  def self.update_recommendations
    Database.db[recommendation_results.name].find.each do |result|
      Person.find(result["_id"]).update_attributes(:recommendations => result["value"])
    end
  end
  
  def self.recommendation_results
    @recommendation_results ||= Recommendation.run
  end
  
end
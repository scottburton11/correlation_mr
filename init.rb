require 'rubygems'
require 'mongoid'
require 'mongoid_config'

require 'json'
require 'pp'
require 'lib/mapreduce'
require 'lib/database'
require 'lib/standard_additions/text_formatting'

Dir[File.expand_path(File.dirname(__FILE__) + "/lib/algorithm/**/*.rb")].each {|file| require file}
Dir[File.expand_path(File.dirname(__FILE__) + "/lib/models/**/*.rb")].each {|file| require file}

include TextFormatting
include Algorithm

Database.load

title "Starting the correlation algorithm:"

title "Running the Pearson Correlation and saving similarity scores back to the database:"
description "The Pearson Correlation scores between -1 and 1, with 1 indicating strong similarity and -1 indicating strong dissimilarity. An interesting feature of the Pearson Correlation is its inherint normalization - if two datasets generally agree, but vary in the width of their scoring range, it will still indicate a that they are similar. We will save the scores for each person in the format 'person_you_follow' => 'similarity_score'."
Person.update_scores

title "Making recommendations:"
description "For each person you follow, and every location they have scored, we multiply our similarity score to them by their score of the location. We then sum the scores of everyone you follow for each location. To equalize the ratings, we divide by the sum of your similarity scores for those reviewers who have reviewed the location. Then we save the scores for each recommendation in the format 'location' => 'score'."
Person.update_recommendations

title 'Here is what we got:'

Person.all.each do |person|
  puts "#{person.name}: #{person.recommendations.inspect}"
end
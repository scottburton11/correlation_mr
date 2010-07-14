require 'rubygems'
require 'mongo'
require 'json'
require 'pp'

module MR
  extend self
    
  def load
    db.collection("people").drop
    db.collection("people").insert(people_json)
  end

  def db
    @db ||= Mongo::Connection.new.db("correlation")
  end

  def people
    db.collection("people")
  end
  
  def people_json
    @people ||= JSON.parse(File.read("./people_reviews_2.json"))
  end

  def run
    load
    results = people.map_reduce(map, reduce, {:scope => {"people" => people_json}})
    db.collection(results.name).find.each do |person|
      pp person
    end
  end
  
  def map
    raise RuntimeError, "called MR module method\n\nOverwrite this with a #map method in the receiving class containing a string describing a Javascript function:\n\ndef map\n  \"function(){};\"\nend\n\n"
  end
  
  def reduce
    raise RuntimeError, "called MR module method\n\nOverwrite this with a #reduce method in the receiving class containing a string describing a Javascript function:\n\ndef reduce\n  \"function(key, values){};\"\nend\n\n"
  end
end

class Euclidian
  extend MR
  class << self
    
    def run
      puts "Calculating Euclidian distances:\n\n"
      super
    end
    
    def map
      "function() {
        var matches = [];
        for (var pi = 0; pi < people.length; pi++) {        
          var person = people[pi];
          for (var ri = 0; ri < this.reviews.length; ri++) {
            var review = this.reviews[ri];
            //if (this.name == person.name) return;
            for (var pri = 0; pri < person.reviews.length; pri++) {
              var person_review = person.reviews[pri];
              if(review.name == person_review.name) {
                matches.push({name: person.name, distance: Math.pow((review.score - person_review.score), 2)});
              };
            }
          }
        }
        emit(this.name, matches);      
      };"
    end

    def reduce
      %Q-
        function(person, influencer_scores) {
         var list = {};
         var sums = {};
         var scores = influencer_scores[0];
         //for (influencer in scores) {
        //   if (sums[influencer.name] == undefined) {
        //     sums[influencer.name] = 0;
        //   };
        //   sums[influencer.name] += influencer.distance;
        // }

        for(var i = 0; i < scores.length; i++) {
          if (sums[scores[i].name] == undefined) {
            sums[scores[i].name] = 0;
          };
          sums[scores[i].name] += scores[i].distance 
        }
         for (influencer in sums) {
           list[influencer] = 1/(1+sums[influencer]);
         }
         return list;
        };
      -
    end
  end
end

class Pearson
  extend MR
  class << self
    def map
      %Q$
      function(){
        var raw_scores = [];
        var squared_scores = [];
        var score_products = [];
        var total_matches = {};
        for (var pi = 0; pi < people.length; pi++) {        
          var person = people[pi];
          for (var ri = 0; ri < this.reviews.length; ri++) {
            var review = this.reviews[ri];
            for (var pri = 0; pri < person.reviews.length; pri++) {
              var person_review = person.reviews[pri];
              if(review.name == person_review.name) {
                raw_scores.push({name: person.name, person_score: person_review.score, my_score: review.score});
                squared_scores.push({name: person.name, person_score: Math.pow(person_review.score, 2), my_score: Math.pow(review.score, 2)});
                score_products.push({name: person.name, score: (person_review.score * review.score)});
                
                if (total_matches[person.name] == undefined) {
                  total_matches[person.name] = 0;
                };
                total_matches[person.name] += 1;
              };
            }
          }
        }
        
        emit(this.name, {scores: raw_scores, squares: squared_scores, products: score_products, total_matches: total_matches});
      };
      $
    end
    
    def reduce_
      %Q$
      function(key, values) {
        return values[0];
      }
      $
    end
    
    def reduce
      %Q$
      function(key, values) {
         var list = {};
         var score_sums = {};
         var my_score_sums = {};
         var square_sums = {};
         var my_square_sums = {};
         var product_sums = {};
         var scores = values[0]["scores"];
         var squares = values[0]["squares"];
         var products = values[0]["products"];
         var total_matches = values[0]["total_matches"];

        for(var i = 0; i < scores.length; i++) {
          if (score_sums[scores[i].name] == undefined) {
            score_sums[scores[i].name] = 0;
            my_score_sums[scores[i].name] = 0;
          };
          score_sums[scores[i].name] += scores[i].person_score;
          my_score_sums[scores[i].name] += scores[i].my_score;
           
          if (square_sums[squares[i].name] == undefined) {
            square_sums[squares[i].name] = 0;
            my_square_sums[squares[i].name] = 0;
          };
          square_sums[squares[i].name] += squares[i].person_score;
          my_square_sums[squares[i].name] += squares[i].my_score;
           
          if (product_sums[products[i].name] == undefined) {
            product_sums[products[i].name] = 0;
          };
          product_sums[products[i].name] += products[i].score;
           
        }
        
        for (person in score_sums) {
          // var length = scores.length;
          // var length = 0;
          // for (var l = 0; l < scores.length; l++) {
          //  if (scores[l].name == person) {
          //    length += 1;
          //  };
          // }
          var length = total_matches[person];
          var numerator = product_sums[person] - ((score_sums[person]*my_score_sums[person])/length);
          var denominator = Math.sqrt((square_sums[person] - Math.pow(score_sums[person],2)/length) * (my_square_sums[person] - Math.pow(my_score_sums[person],2)/length));
          if (denominator == 0) {
            list[person] = 0;
          }
          else {
            list[person] = numerator/denominator;
          };
        
        } 
         
        //return {scores: score_sums, squares: square_sums, products: product_sums, my_score_sums: my_score_sums, my_square_sums: my_square_sums}; 
         
        return list;
      };
      $
    end
  end
end

# Euclidian.run
Pearson.run
class Pearson
  extend MapReduce
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

          var length = total_matches[person];
          var numerator = product_sums[person] - (score_sums[person]*my_score_sums[person]/length);
          var denominator = Math.sqrt((square_sums[person] - Math.pow(score_sums[person],2)/length) * (my_square_sums[person] - Math.pow(my_score_sums[person],2)/length));
          if (denominator == 0) {
            list[person] = 0;
          }
          else {
            list[person] = numerator/denominator;
          };
        
        } 
         
         return list;
        // return {scores: score_sums, my_scores: my_score_sums, squares: square_sums, my_squares: my_square_sums, products: product_sums, matches: total_matches}
      };
      $
    end
  end
end
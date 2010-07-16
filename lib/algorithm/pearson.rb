module Algorithm
  class Pearson
    extend MapReduce
    class << self
      def map
        %Q@
        function(){
          var raw_scores = [];
          var squared_scores = [];
          var score_products = [];
          var total_matches = {}; 
          var me = this;
    
          db.people.find({name: {$in: this.follows}}).forEach(function(person){
            for (this_review in me.reviews){
              if (this_review in person.reviews) {
                var person_review_score = person.reviews[this_review];
                var my_review_score = me.reviews[this_review];
                raw_scores.push({name: person.name, person_score: person_review_score, my_score: my_review_score});
                squared_scores.push({name: person.name, person_score: Math.pow(person_review_score, 2), my_score: Math.pow(my_review_score, 2)});
                score_products.push({name: person.name, score: (person_review_score * my_review_score)});

                if (total_matches[person.name] == undefined) {
                  total_matches[person.name] = 0;
                };
                total_matches[person.name] += 1;
              }
            }
          })

          emit(this._id, {scores: raw_scores, squares: squared_scores, products: score_products, total_matches: total_matches});
        };
        @
      end
      
      def reduce
        %Q@
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

        };
        @
      end
    end
  end
end
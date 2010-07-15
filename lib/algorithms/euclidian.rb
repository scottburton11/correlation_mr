class Euclidian
  extend MapReduce
  class << self
        
    def map
      %Q$
      function() {
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
      };
      $
    end

    def reduce
      %Q$
        function(person, influencer_scores) {
         var list = {};
         var sums = {};
         var scores = influencer_scores[0];

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
      $
    end
  end
end
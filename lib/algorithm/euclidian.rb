module Algorithm
  class Euclidian
    extend MapReduce
    class << self

      def map
        %Q@
        function() {
          var matches = [];
          var me = this;
    
          db.people.find({name: {$in: this.follows}}).forEach(function(person){
            for (this_review in me.reviews){
              if (this_review in person.reviews) {
                matches.push({name: person.name, distance: Math.pow((me.reviews[this_review] - person.reviews[this_review]), 2)});
              }
            };
          })

          emit(this.name, matches);      
        };
        @
      end

      def reduce
        %Q@
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
             list[influencer] = 1/(1+(Math.sqrt(sums[influencer])));
           }
           return list;
          };
        @
      end
    end
  end
end
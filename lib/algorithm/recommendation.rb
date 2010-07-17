class Recommendation
  extend MapReduce
  class << self
    def run
      Database.people.map_reduce(map, reduce)
      # Database.db[results.name].find.each{|result| puts result.inspect }
    end
    
    def map
      File.read(File.expand_path(File.dirname(__FILE__) + "/js/#{self.name.downcase}_map.js")).gsub(/[\n\t]/, " ")      
      # %Q#function() {
      #   var location_scores = {};
      #   var similarities = {}
      #   var me = this;
      #    db.people.find({name: {$in: this.follows}}).forEach(function(person){
      #     for(location in person.reviews) {
      #       if(location_scores[location] == undefined){
      #         location_scores[location] = [];
      #       }
      #       if(similarities[location] == undefined){
      #         similarities[location] = [];
      #       }
      #       location_scores[location].push((person.reviews[location] * me.scores[person.name]));
      #       similarities[location].push(me.scores[person.name]);
      #     }
      #    });
      #   emit(me._id, {location_scores: location_scores, similarities: similarities});
      # };
      # #
    end
    
    def reduce
      File.read(File.expand_path(File.dirname(__FILE__) + "/js/#{self.name.downcase}_reduce.js")).gsub(/[\n\t]/, "")
      # %Q#
      #   function(key, values) {
      #     return {values: values};
      #   }
      # #
    end
  end
end
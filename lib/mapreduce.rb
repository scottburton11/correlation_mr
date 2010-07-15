module MapReduce
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
    @people ||= JSON.parse(File.read("./people_reviews_3.json"))
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
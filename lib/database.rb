class Database
  class << self
    def load
      db.collection("people").drop
      db.collection("locations").drop
      # db.collection("people").insert(people_json)
      people_json.each {|attributes| Person.create(attributes)}
      locations_json.each {|attributes| Location.create(attributes)}
    end

    def db
      @db ||= Mongo::Connection.new.db("correlation")
    end

    def people
      db.collection("people")
    end

    def locations
      db.collection("locations")
    end

    def people_json
      @people ||= JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/../fixtures/people_reviews_3.json")))
    end

    def locations_json
      @locations ||= JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/../fixtures/locations.json")))
    end
  end
end
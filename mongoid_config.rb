Mongoid.configure do |config|
  name = "correlation"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
  config.persist_in_safe_mode = false
end

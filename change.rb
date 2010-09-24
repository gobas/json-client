class Change < VUser
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
    self.instance_variable_set("@session", super)
  end
  
  def self.now session
    self.since(self.time)
  end
  
  def self.time session
    puts "Getting current Server Time"
    return session.get(:path => "/changes.json")["time"]
  end
  
  def self.since session, time
    return session.get(:path => "/changes.json?last_sync=#{url_escape(time)}")
  end
end
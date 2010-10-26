class Customer < VUser
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
    self.instance_variable_set("@session", super)
  end
  
  
  def update attributes
    Customer.update self.session, self, attributes
  end
  
  def destroy
    Customer.delete self.session, self
  end
  
  def get
    Customer.get self.session, self
  end
  
  def self.create session, attributes
    puts "Creating Customer"
    return Customer.new(attributes.merge(:uuid => session.post(:path => "/customers.json", :params => {:customer=> attributes.to_json})["uuid"]))
  end 
  
  def self.get session, uuid
     uuid = uuid.class == Customer ? uuid.uuid : uuid
     puts "Getting Customer with UUID: #{uuid}"

     return make_obj(session.get(:path => "/customers/#{uuid}.json"), session)
   end
  
  
  def self.update session, uuid, attributes    
    uuid = uuid.class == Customer ? uuid.uuid : uuid
    puts "Updating Customer with UUID: #{uuid}"
    
    return session.put(:path => "/customers/#{uuid}.json", :params => {:customer => attributes.to_json})
  end
  
  def self.delete session, uuid    
    uuid = uuid.class == Customer ? uuid.uuid : uuid
    puts "Deleting Customer with UUID: #{uuid}"
    
    return session.delete(:path => "/customers/#{uuid}.json")
  end
  
end
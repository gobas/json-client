class User < VUser
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
    self.instance_variable_set("@session", super)
  end
  
  def update attributes, file = nil
    User.update self.session, self.uuid, attributes, file
  end
  
  def destroy
    User.destroy self.session, self.uuid
  end
  
  def get
    User.get self.session, self.uuid
  end

  def self.get session, uuid
    uuid = uuid.class == User ? uuid.uuid : uuid
    puts "Getting User #{uuid}"
    return  make_obj(session.get(:path => "/users/#{uuid}.json"), session)
  end

  def self.all session
    puts "Getting Users"
    users = session.get(:path => "/users.json")
    users.collect! {|user| make_obj(user, session)}
    #users.collect! {|user| user.session = session }
    return users
  end
  
  def self.create session, attributes, file = nil
    attributes[:password_confirmation] = attributes[:password] unless attributes[:password_confirmation]
    if file
      return User.new(attributes.merge(:uuid => session.post(:path => "/users.json", :user => attributes.to_json, :file => file)["uuid"]))
    else
      return User.new(attributes.merge(:uuid => session.post(:path => "/users.json", :params => {:user => attributes.to_json})["uuid"]))
    end
  end

  def self.update session, uuid, attributes, file = nil
    uuid = uuid.class == User ? uuid.uuid : uuid
    return session.put(:path => "/users/#{uuid}.json", :user => attributes.to_json, :file => file)
  end
  
  def self.destroy session, uuid
    uuid = uuid.class == User ? uuid.uuid : uuid
    return session.delete(:path => "/users/#{uuid}.json")
  end

end
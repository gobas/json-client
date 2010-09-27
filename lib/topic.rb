class Topic < VUser
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
    self.instance_variable_set("@session", super)
  end
  
  def destroy
    Topic.delete self.session, self
  end
  
  def get
    Topic.get self.session, self
  end
  
  def update attributes
    Topic.update self.session, self, attributes
  end
  
  def medias
    Media.all self.session, self.uuid
  end
  
  def create_media attributes, file = nil
    Media.create self.session, self.uuid, attributes, file
  end
  
  def users
    Topic.users self.session, self.uuid
  end
  
  def invite attributes
    Topic.invite self.session, self.uuid, attributes
  end
  
  def kick uuid
    uuid = uuid.class == User ? uuid.uuid : uuid
    Topic.kick self.session, self.uuid, uuid
  end
  
  def leave uuid
    uuid = uuid.class == User ? uuid.uuid : uuid
    Topic.kick self.session, self.uuid, uuid
  end
  
  def update_scope scope = nil
    Topic.update_scope self.session, self, scope
  end
  
  def update_subscription id, attributes
    Topic.update_subscription self.session, self.uuid, id, attributes
  end
  
  def self.update_scope session, uuid, scope = nil
      uuid = uuid.class == Topic ? uuid.uuid : uuid
      puts "Setting #{scope} as scope for #{uuid}"
      if scope != nil
        return session.post(:path => "/topics/#{uuid}/scope.json",:params => {:scope => {:scope => scope}.to_json})
      else
        return session.get(:path => "/topics/#{uuid}/scope.json")
      end
  end
  
  def self.kick session, uuid, id
    uuid = uuid.class == Topic ? uuid.uuid : uuid
    id = id.class == User ? id.uuid : id
    puts "Kicking User #{id} From Server"
    return session.delete(:path => "/topics/#{uuid}/subscriptions/#{id}.json")
  end
  
  def self.update_subscription session, uuid, id, attributes
    uuid = uuid.class == Topic ? uuid.uuid : uuid
    id = id.class == User ? id.uuid : id
    puts "Updating Subscription of User #{id}"
    return session.put(:path => "/topics/#{uuid}/subscriptions/#{id}.json", :params => {:subscription => attributes.to_json})
  end
    
  def self.invite session, uuid, attributes
    uuid = uuid.class == Topic ? uuid.uuid : uuid
    puts "Inviting People to Topic #{uuid}"
    return session.post(:path => "/topics/#{uuid}/invites.json", :params => {:invites=> attributes.to_json})
  end
  
  def self.users session, uuid
    uuid = uuid.class == Topic ? uuid.uuid : uuid
    puts "Getting all Users for Topic #{uuid}"
    return make_obj(session.get(:path => "/topics/#{uuid}/subscriptions.json"), session)
  end
  
  def self.all session
    puts "Getting all Topics"
    puts session
    topics =  session.get(:path => "/topics.json")
    topics.collect! {|topic| make_obj(topic, session)}
    return topics
  end
  
  def self.get session, uuid
    uuid = uuid.class == Topic ? uuid.uuid : uuid
    puts "Getting Topic with UUID: #{uuid}"
    
    return make_obj(session.get(:path => "/topics/#{uuid}.json"), session)
  end

  def self.create session, attributes
    puts "Creating Topic"
    return Topic.new(attributes.merge(:uuid => session.post(:path => "/topics.json", :params => {:topic=> attributes.to_json})["uuid"]))
  end 
  
  def self.update session, uuid, attributes    
    uuid = uuid.class == Topic ? uuid.uuid : uuid
    puts "Updating Topic with UUID: #{uuid}"
    
    return session.put(:path => "/topics/#{uuid}.json", :params => {:topic => attributes.to_json})
    #status = session.put(:path => "/topics/#{uuid}.json", :params => "topic='#{attributes.to_json}'")
    #if status["ok"] == true
    #  Topic.get status["id"]
    #else 
     # return status
    #end
  end

  def self.delete session, uuid    
    uuid = uuid.class == Topic ? uuid.uuid : uuid
    puts "Deleting Topic with UUID: #{uuid}"
    
    return session.delete(:path => "/topics/#{uuid}.json")
  end
end
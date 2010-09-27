class Invite < VUser  
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
    self.instance_variable_set("@session", super)
  end
  
  def accept
    Invite.accept self.session, self.topic_id, self.uuid
  end
  
  def ignore 
    Invite.destroy self.session, self.topic_id, self.uuid
  end

  def self.all session
    puts "Getting User Invites"
    invites = session.get(:path => "/account/invites.json")
    invites.collect! {|topic| make_obj(topic, session)}
    return invites
  end
  
  def self.accept session, uuid, id
    uuid = uuid.class == Topic ? uuid.uuid : uuid
    id = id.class == Invite ? id.uuid : id
    return session.put(:path => "/topics/#{uuid}/invites/#{id}.json", :params => {:accept => true})
  end
  
  def self.destroy session, uuid, id
    uuid = uuid.class == Topic ? uuid.uuid : uuid
    id = id.class == Invite ? id.uuid : id
    return session.delete(:path => "/topics/#{uuid}/invites/#{id}.json")
  end

end
class Account < VUser
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
    self.instance_variable_set("@session", super)
  end
  
  def update attributes
    Account.update self.session, attributes
  end
  
  def destroy
    Account.destroy self.session 
  end
  
  def medias
    Media.all self.session, "inbox"
  end
  
  def create_media attributes, file
    Media.create self.session, self, attributes, file, true
  end
  
  def self.unreads session
    puts "Getting all Unreads"
    return session.get(:path => "/account/unreads.json")
  end
  
  def self.get session
    puts "Getting User Account"
    x = Account.new(session.get(:path => "/account.json")["user"])
    x.session = session
    return x
  end
  
  def self.update session, attributes
    return session.put(:path => "/account.json", :params => {:user => attributes.to_json })
  end
  
  def self.destroy session
    return session.delete(:path => "/account.json")
  end

end
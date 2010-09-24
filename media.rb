class Media < VUser
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
    self.instance_variable_set("@session", super)
  end
  
  def move topic
    Media.update(self.session, self, {:topic_id => topic.uuid})
  end
  
  def delete
    Media.delete self.session, self
  end
  
  def update attributes, file = nil
    Media.update self.session, self, attributes, file
  end
  
  def read
    Media.read self.session, self
  end
  
  def get
    Media.get self.session, self
  end
  
  def unread
    Media.unread self.session, self
  end
  
  
  def get_from_convert
    puts "Getting Media File from Convert Controller"
    return make_obj(@session.get(:path => "/convert/#{self.uuid}.json"), @session)
  end
  
  def push_to_convert attributes, file
    puts "Puts File to Convert"
    session.put(:path => "/convert/#{self.uuid}.json", :media => attributes.to_json, :file => file)
  end
    
  def self.all session, topic_id
    topic_id = topic_id.class == Topic ? topic_id.uuid : topic_id
    puts "Getting all Media Items of Topics #{topic_id}"
    path = topic_id == "inbox" ? "/account/inbox" : "/topics/#{topic_id}"
    
    medias = session.get(:path => "#{path}/medias.json").collect! {|media| make_obj(media, session)}
    return medias
  end
  
  def self.get session, media_id
    media_id = media_id.class.superclass == Media ? media_id.uuid : media_id
    media_id = media_id.class == Media ? media_id.uuid : media_id
    puts "Getting Media with UUID: #{media_id}"
    return make_obj(session.get(:path => "/medias/#{media_id}.json"), session)
  end

  def self.create session, topic_id, attributes, file = nil, inbox = nil
    topic_id = topic_id.class == Account ? topic_id.inbox["uuid"] : topic_id
    topic_id = topic_id.class == Topic ? topic_id.uuid : topic_id
    
    if inbox
      path = "/account/inbox/medias.json"
    else       
      path = "/topics/#{topic_id}/medias.json"
    end
    
    puts "Creating Media in Topic #{topic_id}"
    
    unless attributes.is_a? Hash
      if attributes.is_a? String
        attributes = {:title => attributes}
      end
    end
    
    if file != nil
      args = {:path => path, :media => attributes.to_json, :file => file.strip}
    else
      params = {}
      params[:media] = attributes.to_json
      args = {:path => path, :params => params}
    end
    
    return Media.new(attributes.merge(:uuid => session.post(args)["uuid"]))
    #Media.get
  end 
  
  def self.update session, media_id, attributes, file = nil
    media_id = media_id.class.superclass == Media ? media_id.uuid : media_id
    puts "Updating Media with UUID: #{media_id}"
    
    if file.nil?
      return  session.put(:path => "/medias/#{media_id}.json", :params => { :media => attributes } )
    else  
      return  session.put(:path => "/medias/#{media_id}.json", :media => attributes.to_json, :file => file)
    end
  end

  def self.delete session, media_id
    media_id = media_id.class.superclass == Media ? media_id.uuid : media_id
    puts "Deleting Media with UUID: #{media_id}"
    
    return session.delete(:path => "/medias/#{media_id}.json")
  end
  
  def self.read session, media_id
    media_id = media_id.class.superclass == Media ? media_id.uuid : media_id
    puts "Reading Media with UUID: #{media_id}"
    return session.put(:path => "/medias/#{media_id}/read.json", :params => {:unread => true})
  end
  
  def self.unread session, media_id
    media_id = media_id.class.superclass == Media ? media_id.uuid : media_id
    puts "Unreading Media with UUID: #{media_id}"
    return session.put(:path => "/medias/#{media_id}/unread.json", :params => {:unread => true})
  end
end

class Notice < Media
end

class Video < Media
end

class Picture < Media
end

class Audio < Media
end
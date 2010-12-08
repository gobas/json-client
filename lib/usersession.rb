class UserSession
  attr_accessor :host, :port, :user, :password
  $request_count = 0
 
  def initialize(options)
    @host = options[:host]
    @port = options[:port]
    @user = options[:user]
    @password = options[:password]
    @ssl = options[:ssl].nil? ? false : true
    $request_count = 0
  end
  
  def get options
    self.call(options.merge({:method => "GET"}))
  end
  
  def post options
    self.call(options.merge({:method => "POST"}))
  end
  
  def put options
    self.call(options.merge({:method => "PUT"}))
  end
  
  def delete options
    self.call(options.merge({:method => "DELETE"}))
  end

  def call options
    method = options[:method]
    path = options[:path]
    unless options[:params]
      pp "Running: #{method} on #{server_path}#{path}"
    else
      pp "Running: #{method} on #{server_path}#{path} with params #{options[:params]}"
    end
    url = "#{server_path}#{path}"
    if options[:file]
      
      resource = RestClient::Resource.new "#{server_path}", :multipart => true
    else
      resource = RestClient::Resource.new "#{server_path}", :content_type => :json, :accept => :json
    end
    
    begin
       if options[:params]
         g = eval("resource[\"#{path}\"].#{method.downcase}(#{options[:params].inspect})")
       elsif options[:file] && options[:media]
         g = eval("resource[\"#{path}\"].#{method.downcase}(:file => File.new('#{options[:file]}', 'rb'), :media => '#{options[:media]}')")
       elsif options[:file] && options[:user]
         g = eval("resource[\"#{path}\"].#{method.downcase}(:file => File.new('#{options[:file]}', 'rb'), :user => '#{options[:user]}')")
       else
         g = eval("resource[\"#{path}\"].#{method.downcase}()")
       end
       response = g
       
       pp "Server Response: #{response} Status: #{response.code unless response.code.nil?}"
     rescue => e
       puts e.inspect
     end
    
    if response
      if response["ok"]
        return JSON.parse(response)
      elsif response["error"]
        return JSON.parse(response)
      elsif response["time"]
        return JSON.parse(response)
      else  
         begin
            return JSON.parse(response)
              rescue JSON::JSONError => e
              puts data
              exception = RuntimeError.new(e.message)
              exception.set_backtrace(e.backtrace)
              raise exception
            end
          end
      end
    end
  
  def server_path
    if self.user.is_a?(Hash)
      username = self.user["email"]
      if username.nil? || username.blank?
        username = self.user[:email].sub("@", "%40")
      end
    else
      username = self.user
    end
    
    return "http://#{username.sub("@", "%40")}:#{self.password}@#{self.host}:#{self.port}"
  end
  def parse_json(response)
  
  end  
  
end
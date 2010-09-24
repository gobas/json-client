#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'pp'
require 'rest_client'
require 'usersession'

def first_user
  return VUser.new(:user => "seb", :host => "failinc.sharenotes.de")
end
def second_user
  return VUser.new(:user => "aaron", :host => "failinc.sharenotes.de")
end

def reload
  load "client.rb"
  load 'topic.rb'
  load 'account.rb'
  load 'change.rb'
  load 'media.rb'
  load 'usersession.rb'
  load 'user.rb'
  load 'invite.rb'
end

def url_escape(string)
string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
'%' + $1.unpack('H2' * $1.size).join('%').upcase
end.tr(' ', '+')
end

def make_obj obj, session
    if obj.is_a? Array
      obj.collect! { |o|  o}
    else
      x = eval(obj.keys[0].capitalize).new(obj[obj.keys[0]])
      x.session = session
      return x
    end
end


class VUser
  attr_accessor :user, :password, :host, :port, :session
  
  def initialize(options)
    user = options[:user].nil? ? "test" : options[:user]
    password = options[:password].nil? ? "test" : options[:user]
    host = options[:host].nil? ? "gobas.sharenotes.de" :  options[:host]
    port = options[:port].nil? ? "80" : options[:port] 
    @session = UserSession.new(:host => host, :port => port, :user => user, :password => password)
  end
  
  def session
    @session
  end
  
  def unreads
    Account.unreads self.session
  end
  
  def topics    
    Topic.all self.session
  end
  
  def get_topic id
    Topic.get self.session, id
  end
  
  def create_topic attributes
    unless attributes.is_a? Hash
      if attributes.is_a? String
        attributes = {:name => attributes}
      end
    end
    Topic.create self.session, attributes 
  end
  
  def users
     User.all self.session
   end

   def create_user attributes, file = nil
     User.create self.session, attributes, file
   end
  
  def get_user id
    User.get self.session, id
  end
  
  def account
    Account.get self.session
  end
  
  def invites
    Invite.all self.session
  end  
    
  def current_time
    Change.time session
  end
end



require 'topic'
require 'media'
require 'user.rb'
require 'invite.rb'
require 'account'
require 'change'
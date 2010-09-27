#!/usr/bin/ruby
$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'client'
require 'yaml'

#######################
# Testing Share Notes #
#######################

# Sample Images
@samp_images = "../sample/images"
@samp_videos = "../sample/videos"
@samp_audios = "../sample/audio"

# Global Config
@host = "failinc.localhost.local"
@port = "8080"

# First and Second Default User
@@first_user = {}
@@first_user[:user] = "test"
@@first_user[:host] = @host
@@first_user[:port] = @port

@@second_user = {}
@@second_user[:user] = "aaron"
@@second_user[:host] = @host
@@second_user[:port] = @port

# Load Test runs
$runs = YAML.load_file("./runs.yml")

# Log
$LOG = []

def get_sample_media type, number=1
  case type
  when "image"
    path = @samp_images
  when "video"
    path = @samp_videos
  when "audio"
    path = @samp_audios
  else
    puts "You have to choose the right type for medias!"
    path = ""
  end
  
  files = Dir.entries(path)
  media = []
  number.times do
    ra = rand(files.size)
    if ra <= 2 then ra+2 end
    media << path+"/"+files[ra]
  end
  if number == 1 then
    return media[0].to_s
  else
    return media
  end
end

def print_log
  puts "###### LOG #####"
  $LOG.each do |i|
    puts i
  end
end

def random_string length=10
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ1234567890'
  word = ''
  length.times { word << chars[rand(chars.size)] }
  word
end

def create_user
  $runs['user'].each_value do |user|
    puts user.inspect
    first_user.create_user({ :login => user['login'], :password => user['password'], :email => user['email'] }, get_sample_media("image").to_s)
    $LOG << "Created user #{user['login']}"
  end
end

def get_random_topic user, count=1
  top_count = user.topics.size
  n = rand(top_count)
  
  if count == 1 then
    if top_count >= 1 then
      return user.topics[n]
    end
    if top_count == 0 then
      return user.create_topic :name => random_string
    end
  else
  
    ar = []
    if top_count >= count then
      count.times do
        ar << user.topics[n]
        n = rand(top_count)
      end
      return ar
    else
      top_count.times do
        ar << user.topics[n]
        n = rand(top_count)
      end
      (count - top_count).times do
        ar << (user.create_topic :name => random_string(15))
      end
      return ar
    end
    
  end
end

def creations
  running_order = $runs['creations'].keys.sort
  i=0
  running_order.size.times do
    run = running_order[i]
    $runs['creations'][run].each_pair do |k, v|
      user= VUser.new(:user => k, :host => @host, :port => @port)
      #$LOG << v.inspect
      v.each_pair do |ke, va|
        if ke == "topics" then
          va.times do
            s = random_string
            user.create_topic :name => s
            $LOG << "(#{run})Created Topic #{s} for user #{user.account.login}"
          end
        end
        if ke == "images" then
          va.times do
            s = random_string
            img = get_sample_media("image")
            top = get_random_topic(user)
            top.create_media({:title => s}, img)
            $LOG << "(#{run})Created Image #{s} in Topic #{top.name} with image #{img}"
          end
        end
        if ke == "videos" then
          va.times do
            s = random_string
            vid = get_sample_media("video")
            top = get_random_topic(user)
            top.create_media({:title => s, :notice => random_string}, vid)
            $LOG << "(#{run})Created Video #{s} in Topic #{top.name} with video #{vid}"
          end
        end
        if ke == "audios" then
          va.times do
            s = random_string
            aud = get_sample_media("audio")
            top = get_random_topic(user)
            top.create_media({:title => s, :notice => random_string}, aud)
            $LOG << "(#{run})Created Audio #{s} in Topic #{top.name} with audio #{aud}"
          end
        end
        #User von User erstellen lassen is evtl. noch bisschen crap
        if ke == "user" then 
          va.each_value do |param|
            user.create_user({ :login => param['login'], :password => param['password'], :email => param['email'] }, get_sample_media("image").to_s)
            $LOG << "(#{run})Created User #{param['login']} with user #{user.account.login}"
          end
        end
        if ke == "invites" then
          va.each_pair do |u, n|
            invited_user = VUser.new :user => u
            if n == 1 then
              top = get_random_topic(user)
              top.invite :email => invited_user.account.email
              $LOG << "(#{run})User #{user.account.login} invited #{u} for Topic #{top.name}, #{n} in total"
            else
              ts = get_random_topic(user, n)
              puts ts.class
              ts.each do |n|
                n.invite :email => invited_user.account.email
                $LOG << "(#{run})User #{user.account.login} invited #{u} for Topic #{n.name}, #{ts.size} in total"
              end
            end
            #n.times do
            #  top = get_random_topic(user)
            #  top.invite :email => invited_user.account.email
            #  $LOG << "(#{run})User #{user.account.login} invited #{u} for Topic #{top.name}, #{n} in total"
            #end
          end
        end
        if ke == "accept" then
          i = 0
          invites = user.invites
          i_before = user.invites.size
          if invites.size >= va then
            va.times do
              invites[i].accept
              $LOG << "(#{run})User #{user.account.login} has now #{user.invites.size}(#{i_before} before) invitation(s) and accepted #{i+1} of #{va.to_s}"
              i = i + 1
            end
          else
            $LOG << "#{run})User #{user.account.login} wants to accept an invitation, but has no one"
          end
        end
        if ke == "ignore" then
          i = 0
          invites = user.invites
          i_before = user.invites.size
          if invites.size >= va then
            va.times do
              user.invites[i].ignore
              $LOG << "(#{run})User #{user.account.login} has now #{user.invites.size}(#{i_before} before) invitation(s) and ignored #{i+1} of #{va.to_s}"
              i = i + 1
            end
          else
            $LOG << "(#{run})User #{user.account.login} wants to ignore an invitation, but has no one"
          end
        end
      end
    end
    i = i + 1
  end
end


# RUN
#create_user
creations
print_log

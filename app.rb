require 'logger'
require 'rubygems'
require 'sinatra'
require 'json'
require 'haml'

require 'model'

require 'demo'

LOGGER = Logger.new(File.join(File.dirname(__FILE__),'log','greasi.log'))

get '/' do
  haml <<-HAML
%html{html_attrs}
  %head
    %title Greasi
  %body
    %h1
      %a(href = "./scripts/googleimages_crawler.user.js") googleimages_crawler.user.js
    %h1
      %a{:href => UrlQueue.next_url} #{UrlQueue.next_url}
  HAML
end

get '/queue' do
  haml <<-HAML
%html{html_attrs}
  %script{:type => "text/javascript",
          :src => "http://ajax.googleapis.com/ajax/libs/jquery/1.3.1/jquery.min.js"}
  :javascript
    $(function(){
      var interval = 10 * 1000;
      var timer = setInterval(function(){
        $.getJSON("./latest.json", function(json){
          $("#all").text(json.all);
          $("#queueing").text(json.queueing);
          $("#processing").text(json.processing);
          $("#finished").text(json.finished);
        });
      },interval);
    });
  %body
    %h3 All:
    %h2#all #{UrlQueue.count}
    %h3 Queueing:
    %h2#queueing #{UrlQueue.candidates.count}
    %h3 Processing:
    %h2#processing #{UrlQueue.processing.count}
    %h3 Finished:
    %h2#finished #{UrlQueue.finished.count}
    %form{:method => "post", :action => "./requeue"}
      %button{:type => "submit", :value=> "requeue"} requeue
  HAML
end

get '/latest.json' do
  content_type :json
  JSON.unparse({
    :all        => UrlQueue.count,
    :queueing   => UrlQueue.candidates.count,
    :processing => UrlQueue.processing.count,
    :finished   => UrlQueue.finished.count
  })
end

post '/requeue' do
  UrlQueue.processing.filter{|o| o.updated < Time.now - 5*60}.update(:status => "queueing")
  redirect './queue'
end

post '/' do
  url = params[:url]
  data = params[:data]
  store(url, data)
  next_url = process(url)
  next_url.nil? ? "http://libelabo.jp/greasi/" : "#{next_url}"
end

def store(url, json)
  data = JSON.parse(json)
  LOGGER.info(url)
  LOGGER.info(data.size)
  Result.create(url,json)
end

def process(finished_url)
  UrlQueue.finish(finished_url)
  UrlQueue.next_url(true)
end

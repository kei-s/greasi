require 'rubygems'
require 'sequel'

DB = Sequel.sqlite(File.join(File.dirname(__FILE__),"db","greasi.sqlite"))

class UrlQueue < Sequel::Model
  DB.create_table :url_queues do
    primary_key :id
    String      :url,    :unique  => true
    String      :status, :default => "queueing"
    Time        :updated
  end unless DB.table_exists? :url_queues

  self.subset(:candidates, :status => "queueing")
  self.subset(:processing, :status => "processing")
  self.subset(:finished,   :status => "finished")

  def self.finish(url)
    url_queue = self.find(:url => url)
    url_queue.update(:status => "finished",   :updated => Time.now) unless url_queue.nil?
  end

  def self.next_url(processing=false)
    url_queue = self.candidates.first
    if url_queue.nil?
      return nil
    end
    if processing
      url_queue.update(:status => "processing", :updated => Time.now) unless url_queue.nil?
    end
    url_queue.url
  end
end

class Result < Sequel::Model
  DB.create_table :results do
    primary_key :id
    String :url
    String :data
    Time   :fetched
  end unless DB.table_exists? :results

  def self.create(url, data)
    self.insert(:url => url, :data => data, :fetched => Time.now)
  end
end

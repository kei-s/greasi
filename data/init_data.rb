require 'model'

data = []
["札幌","Sapporo","北海道","Hokkaido","Ruby","スープカレー","舟盛り","スイーツ","ファイターズ","Rails"].each do |query|
  (0..1000).step(20) do |i|
    url = "http://images.google.co.jp/images?gbv=2&hl=ja&safe=off&q=#{URI.escape(query)}&sa=N&start=#{i}&ndsp=20"
    data.push({:url => url})
  end
end

UrlQueue.multi_insert(data.sort_by{rand})

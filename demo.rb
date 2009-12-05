get '/demo' do
  haml <<-HAML
%html{html_attrs}
  %head
    %title greasi demo
    %script{:type => "text/javascript",
            :src => "http://ajax.googleapis.com/ajax/libs/jquery/1.3.1/jquery.min.js"}
    :javascript
      $(function(){
        function loadImages(last) {
          $.getJSON("./demo.json?last="+last, function(json){
            json.forEach(function(data){
              data.data.forEach(function(entry){
                $("<img/>").attr(
                  {src: entry.src, height: entry.height/2, width: entry.width/2}
                ).insertBefore(
                  $("#images img:first")
                )
              });
            });
            next = json.length != 0 ? json[json.length-1].id : last;
            setTimeout(function(){loadImages(next)},500);
          });
        };
        loadImages(#{Result.count});
      });
  %body
    %div
      %img{:src => "http://ruby-sapporo.org/sappororubykaigi/sapporo-rubykaigi.png", :width=>320, :height=>75}
    %div#images
      %img{:src => "http://s3.amazonaws.com/twitter_production/profile_images/57317277/Squarepusher088_a_bigger.PNG"}
  HAML
end

get '/demo.json' do
  last = params[:last]
  content_type :json
  data = Result.filter{|o| o.id > last}.order(:id).map{|i| i.values}.map{|i| {:data=>JSON.parse(i[:data]),:id=>i[:id]}}
  JSON.unparse(data)
end

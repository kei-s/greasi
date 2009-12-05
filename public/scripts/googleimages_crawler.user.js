// ==UserScript==
// @name           googleimages_crawler
// @namespace      http://libelabo.jp/
// @include        http://images.google.co.jp/images*
// @require        http://ajax.googleapis.com/ajax/libs/jquery/1.3.1/jquery.min.js
// ==/UserScript==

(function(){
  function postData(data,callback) {
    var postData = $.param({url: location.href, data: JSON.stringify(data)});
    GM_xmlhttpRequest({
      method:  "POST",
      url:     "http://libelabo.jp/greasi/",
      headers: {'Content-type':'application/x-www-form-urlencoded'},
      data:    postData,
      onload:  callback
    });
  }

  function scrape() {
    var data = $("#imgtb tbody tr td[nowrap]").map(function(){
      var url = location.protocol+"//"+location.host+$("a:first",this).attr("href");
      var image = $("a img",this);
      return {url: url, src: image.attr("src"), height: image.attr("height"), width: image.attr("width")};
    });
    data.enqueue = [];
    return $.makeArray(data);
  }

  function callback(xhr) {
    location.href = xhr.responseText;
  }

  var data = scrape();
  postData(data,callback);
})()


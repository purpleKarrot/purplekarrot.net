
function twitter_callback(tweets)
{
  var statusHTML = [];

  for (var i=0; i<tweets.length; i++)
  {
    var status = tweets[i].text.replace(/((https?|s?ftp|ssh)\:\/\/[^"\s\<\>]*[^.,;'">\:\s\<\>\)\]\!])/g, function(url) {
      return '<a href="'+url+'">'+url+'</a>';
    }).replace(/\B@([_a-z0-9]+)/ig, function(reply) {
      return '<a href="http://twitter.com/'+reply.substring(1)+'">'+reply.substring(1)+'</a>';
    }).replace(/\B#([_a-z0-9]+)/ig, function(tag) {
      return '<a href="http://twitter.com/#!/search?q=%23'+tag.substring(1)+'">'+tag.substring(1)+'</a>';
    });

    statusHTML.push('<li>'+status+'</li>');
  }

  document.getElementById('twitter_update_list').innerHTML = statusHTML.join('');
}


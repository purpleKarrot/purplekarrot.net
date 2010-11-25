
function relative_time(timestamp) {
  var values = timestamp.split(" ");
  timestamp = values[1] + " " + values[2] + ", " + values[5] + " " + values[3];
  var parsed_date = Date.parse(timestamp);
  var relative_to = (arguments.length > 1) ? arguments[1] : new Date();
  var delta = parseInt((relative_to.getTime() - parsed_date) / 1000);
  delta = delta + (relative_to.getTimezoneOffset() * 60);

  if(delta < 120) {
    return 'just now';
  } else if(delta < (60*60)) {
    return (parseInt(delta / 60)).toString() + ' minutes ago';
  } else if(delta < (120*60)) {
    return 'about an hour ago';
  } else if(delta < (24*60*60)) {
    return 'about ' + (parseInt(delta / 3600)).toString() + ' hours ago';
  } else if(delta < (48*60*60)) {
    return 'yesterday';
  } else {
    return (parseInt(delta / 86400)).toString() + ' days ago';
  }
}

function twitter_callback(tweets) {
  var statusHTML = [];
  for (var i=0; i<tweets.length; i++){
    var username = tweets[i].user.screen_name;
    var status = tweets[i].text.replace(/((https?|s?ftp|ssh)\:\/\/[^"\s\<\>]*[^.,;'">\:\s\<\>\)\]\!])/g, function(url) {
      return '<a href="'+url+'">'+url+'</a>';
    }).replace(/\B@([_a-z0-9]+)/ig, function(reply) {
      return  reply.charAt(0)+'<a href="http://twitter.com/'+reply.substring(1)+'">'+reply.substring(1)+'</a>';
    });
    statusHTML.push('<li><span>'+status+'</span> <a style="font-size:85%" href="http://twitter.com/'+username+'/statuses/'+tweets[i].id+'">'+relative_time(tweets[i].created_at)+'</a></li>');
  }
  document.getElementById('twitter_update_list').innerHTML = statusHTML.join('');
}


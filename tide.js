$(function() {
  var apiURL = "http://github.com/api/v2/json/",
   issuesURL = apiURL + "issues/list/schacon/hg-git/open",
      issues = 0

  // cute little issues count in the nav
  $.getJSON(issuesURL + '?callback=?', function(data) {
    if (data.issues)
      $('#issues-link').html('issues <sup>(' + data.issues.length + ')</sup>')
  })

  // back to top. you know... for kids
  $('#top').click(function() {
    $('html,body').animate({scrollTop: 0}, 0)
    return false
  })

  // our changelog is sweet
  if ($('.changelog').length > 0) {
    var commitsURL = apiURL + "commits/list/schacon/hg-git/master"

    $.getJSON(commitsURL + '?callback=?', function(data) {
      var ul = $('<ul id="commits"></ul>')

      $.each(data.commits, function() {
        if (/^Merge/.test(this.message)) return
        ul.append('<li><a href="' + this.url + '">' + this.message + '</a></li>')
      })

      $('h1').after(ul)
    })
  }
})
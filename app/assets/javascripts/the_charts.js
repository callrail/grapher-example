console.log("This Works");

function start() {
  var dropdown = $("#tags");
  dropdown.change(function() {
    console.log( "Handler for .change() called." );
    $.getJSON("/charts/tagdata?tag=" + dropdown[0].value, function(data) {
      console.log("data: ", data);
    });
  });
};

$(function() {
    start();
});

$( ".target" )
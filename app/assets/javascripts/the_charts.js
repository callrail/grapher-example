function start() {
  var dropdown = $("#tag_id");
  dropdown.change(function() {
    $.getJSON("/charts/tag_data?tag=" + dropdown[0].value, function(data) {
      new Chartkick.PieChart("chart-3", data, {"donut":true});
    });
  });
};

$(function() {
    start();
});
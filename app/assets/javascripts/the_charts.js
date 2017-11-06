function tags() {
  var dropdown = $("#tag_id");
  dropdown.change(function() {
    $.getJSON("/charts/tag_data?tag=" + dropdown[0].value, function(data) {
      new Chartkick.PieChart("chart-3", data, {"donut":true});
    });
  });
};

function date_range() {
  var dropdown = $("#date_range");
  dropdown.change(function() {
    $.getJSON("/charts/calls_by_date?date_range=" + dropdown[0].value, function(data) {
      new Chartkick.AreaChart("chart-1", data);
    });
    $.getJSON("/charts/first_vs_repeat?date_range=" + dropdown[0].value, function(data) {
      new Chartkick.BarChart("chart-2", data, {stacked: true});
    });
    $.getJSON("/charts/generate_pie_chart?date_range=" + dropdown[0].value, function(data) {
      new Chartkick.PieChart("chart-3", data, {donut: true});
    });
  });
};

$(function() {
    date_range();
    tags();
});
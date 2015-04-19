var HighchartsController = function () {
  var self = this;
  var chart = null; 
  var element = null;
  var metrics = null;
  var aggregatedData = {};

  function buildURL(){
    var url = window.location.href + "/api?";
    $.each(metrics, function(index, value) {
      url = url + "metrics[]=" + value + "&";
    });
    return url;
  }

  this.initialize = function(metricsList, htmlElement){
    metrics = metricsList;
    element = htmlElement;
    var url = buildURL();

    $.each(["day", "minute", "hour"], function(index, value) {
      $.getJSON(url + "&granularity=" + value, function (data) {
        aggregatedData[value] = data;
        if (index == 2)
          drowChart("day");
      })
    });
    
    
  }

  function getButtons(granularity){
    switch(granularity)
    {
      case "day" :
        return [{type: 'day',count: 7,text: '1w'},{type: 'day',count: 30,text: '1mo'}, {type: 'all',text: 'All'}]
      case "hour" :
        return [{type: 'day',count: 1,text: '1d'},{type: 'day',count: 7,text: '1w'}]
      case "minute" :
        return [{type: 'minute',count: 60,text: '1h'},{type: 'day',count: 1,text: '1d'}]
    }
  }

  function redrowChart(granularity){
    chart.destroy();
    drowChart(granularity);
  }

  $(".granularity button").click(function() {
    redrowChart($(this).data("granularity"));
  })


  function drowChart(granularity){
    element.highcharts('StockChart',  {
      chart: {
        events: {
          load: function() {
            chart = this;
            $.each(metrics, function(index, value) {
              if(aggregatedData[granularity][index] != null) {
                chart.addSeries({
                  id: value,
                  name: value,
                  data: aggregatedData[granularity][index]
                });
              }
            });
          }
        }
      },
      rangeSelector: {
        buttons: getButtons(granularity)
      }
    });  
  }
}


Highcharts.theme = {
  colors: ["#2b908f", "#90ee7e", "#f45b5b", "#7798BF", "#aaeeee", "#ff0066", "#eeaaee","#55BF3B", "#DF5353", "#7798BF", "#aaeeee"],
  title: false,
  navigator: {
    enabled: true
  },
  rangeSelector: {
    enabled: true,
    selected: 0,
    inputEnabled: false
  },
  scrollbar: {
    enabled: true
  },
  xAxis: {
    ordinal: true
  }
}

Highcharts.setOptions(Highcharts.theme);

jQuery(document).on( 'shown.bs.tab', 'a[data-toggle="tab"]', function (e) { // on tab selection event
    jQuery( ".graph-container > div" ).each(function() { // target each element with the .contains-chart class
        var chart = jQuery(this).highcharts(); // target the chart itself
        if (chart != "undefined"){
          chart.reflow() // reflow that chart
        }
        
    });
})


function dashboard_line(selector, data, name){
  
  $(function () {
    $(selector).highcharts({
      
        title: {
          text: name
        },
        legend: {
          enabled: false
        },
        xAxis: {
          type: 'datetime',
          dateTimeLabelFormats : {
                month : '%b',
                year : '%Y'
            }
        },
        navigator: {
          enabled: false
        },
        rangeSelector: {
          enabled: false
        },
        yAxis: {
           lineWidth: 0,
           minorGridLineWidth: 0,
          labels: {
               enabled: false
           },
           minorTickLength: 0,
           tickLength: 0,
           gridLineWidth: 0,
          min: 0
        },
       
        series: data
    });
  });     
}
var HighchartsController = function () {
  var self = this;
  var chart = null; 
  var element = null;
  var metrics = null;
  var granularity = null;
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
    loadDate("day", drowChart);
  }

  function loadDate(currentGranularity, callbackFunction){
    granularity = currentGranularity;
    if (aggregatedData[granularity] == undefined) {
      $.getJSON(buildURL() + "&granularity=" + granularity, function (data) {
        aggregatedData[granularity] = data;
        callbackFunction(data);
      })
    }
    else {
      callbackFunction(aggregatedData[granularity], drowChart)
    }
  }

  function getButtons(){
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
    loadDate(granularity, drowChart);
  }

  $(".granularity button").click(function() {
    redrowChart($(this).data("granularity"));
  })


  function drowChart(data){ 
    element.highcharts('StockChart',  {
      chart: {
        events: {
          load: function() {
            chart = this;
            $.each(metrics, function(index, value) {
              if(data[index] != null) {
                chart.addSeries({
                  id: value,
                  name: value,
                  data: data[index]
                });
                chart.hideLoading();
              }
            });
          }
        }
      },
      rangeSelector: {
        buttons: getButtons()
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
    // breaks: [{ // Nights
    //   from: Date.UTC(2015, 9, 13, 15),
    //   to: Date.UTC(2015, 9, 14, 7),
    //   repeat: 24 * 36e5
    // }, { // Weekends
    //   from: Date.UTC(2015, 4, 17, 15),
    //   to: Date.UTC(2015, 4, 20, 7),
    //   repeat: 7 * 24 * 36e5
    // }]
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

Highcharts.theme = {
   colors: ["#2b908f", "#90ee7e", "#f45b5b", "#7798BF", "#aaeeee", "#ff0066", "#eeaaee",
      "#55BF3B", "#DF5353", "#7798BF", "#aaeeee"],
   chart: {
      backgroundColor: null,
      style: {
         fontFamily: "'Unica One', sans-serif"
      },
      plotBorderColor: '#606063',
      spacingBottom: 10,
      spacingTop: 15,
      spacingRight: 20
   },
  rangeSelector: {
           enabled: true,

           buttons: [{
              type: 'month',
              count: 6,
              text: '6m'
           }, {
              type: 'month',
              count: 12,
              text: '1y'
           },
          {
	          type: 'ytd',
	          text: 'YTD'
          }, 
          {
              type: 'all',
              text: 'All'
           }],
           selected: 0
        },
  
     xAxis: {
      gridLineColor: '#707073',
      lineColor: '#707073',
      minorGridLineColor: '#505053',
      tickColor: '#707073',
      title: {
         style: {
            color: '#A0A0A3'
         }
      },
      tickLength: 0,
      minorTickLength: 0,
      gridLineWidth: 0,
      lineWidth: 0,
      minorGridLineWidth: 0
   },
    scrollbar: {
      enabled: false
   },
   yAxis: {
      
      tickWidth: 1,
      title :
            {
              text: ""
            }
   },

  tooltip: {
      backgroundColor: 'rgba(0, 0, 0, 0.85)',
      pointFormat: '<span style="color:{series.color}">\u25CF</span> {series.name}: <b>{point.y}</b><br/>',
      style: {
         color: '#F0F0F0'
      },
   },
   plotOptions: {
      series: {

        dataGrouping: {
            approximation: "sum",
            enabled: false,
            forced: true,
            units: [['month',[1]]]

        }
      }
   },
   legendBackgroundColor: 'rgba(0, 0, 0, 0.5)',
   background2: '#505053',
   dataLabelsColor: '#B0B0B3',
   textColor: '#C0C0C0',
   contrastTextColor: '#F0F0F3',
   maskColor: 'rgba(255,255,255,0.3)',
   
};

// Apply the theme
Highcharts.setOptions(Highcharts.theme);



jQuery(document).on( 'shown.bs.tab', 'a[data-toggle="tab"]', function (e) { // on tab selection event
    jQuery( ".graph-container > div" ).each(function() { // target each element with the .contains-chart class
        var chart = jQuery(this).highcharts(); // target the chart itself
        if (chart != "undefined"){
          chart.reflow() // reflow that chart
        }
        
    });
})

function adjust_date(x){
  date = new Date(x);
  date.setMonth(date.getMonth() + 1);
  return date
}

function format_date(x, interval){
  if (typeof interval == 'undefined')
    interval = "month";
  
  
  switch(interval) {
    case "month":
        return Highcharts.dateFormat("%B %Y", adjust_date(x))
        break;
    case "year":
        return Highcharts.dateFormat("%Y", adjust_date(x))
        break;
    case "day":
        return Highcharts.dateFormat("%d/%m/%y", adjust_date(x))
        break
  }  
}

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

function apply_filters(){
  var today = new Date();
  
  $('#datepicker input').datepicker({
    startView: 1,
    minViewMode: 1,
    format: "MM yyyy",
    keyboardNavigation: true,
    autoclose: true,
    startDate: new Date(today.setMonth(today.getMonth() - 12)),
    endDate: new Date()      
  }); 
  
  var lastJQueryTS = 0 ;
  $("#datepicker input").datepicker().on("changeDate", function(event){
     var send = true;
     if (typeof(event) == 'object'){
       
       if (event.timeStamp - lastJQueryTS < 300){
         send = false;
      }
      lastJQueryTS = event.timeStamp;
    }
    if (send){
      $.ajax({
        url: window.location.pathname,
        data: {
          start: $("input[name=start]").val(),
          finish: $("input[name=finish]").val()
        },
        dataType: "script"
      });
    }
  }); 
}

function line_chart(data, selector, symbol){
  
  
  $(function () {
    $(selector).highcharts(  {
        title: false,
        colors: ["#03AC42", "#FA6B5B","#51B8F2"  ],
        xAxis: {
          type: 'datetime'
        },
        navigator: {
          enabled: false
        },
        rangeSelector: {
          enabled: data.length > 0 && data[0]["data"].length > 8
        },
        scrollbar: {
          enabled: false
        },
        tooltip: {
           shared: true,
          valueSuffix:  ' ' + symbol
          },
        yAxis: {
            labels: {
            format: '{value} ' + symbol
          },
          min: 0
        },
        plotOptions: {
            spline: {
                marker: {
                    enabled: false
                }
            }
        },
        series: data
    }, function(chart){

            // apply the date pickers
            setTimeout(function () {
                $('input.highcharts-range-selector', $(chart.container).parent())
                .datepicker({startView: 1,minViewMode: 1,format: "yyyy-mm-dd",keyboardNavigation: true, autoclose: true});
            }, 0);
        });
  });
}

function company_sentiment_index_chart(iok, changes ){

  
  $(function () {
    $('#company_sentiment_index_chart').highcharts({
        title: false,
        colors: ["#28D8B2", "#FA6B5B"],
        xAxis: {
                type: 'datetime',
            },
        navigator: {
          enabled: false
        },
        scrollbar: {
          enabled: false
        },
        rangeSelector: {
          enabled: iok.length > 6
        },
   
        yAxis: [{ // Secondary yAxis
            labels: {
                format: '{value}',
            },

        }, {
            gridLineWidth: 0,
            title: {
                text: false,
            },
            labels: {
              format: '{value} %',
            },
            opposite: true
        }],
        tooltip: {
            headerFormat: '<span style="font-size: 10px">{point.key}</span><br/>',
            shared: true
        },
        series: [{
            name: 'Company sentiment index',
            type: 'spline',
            data: iok,
        },
        {
            name: 'Stock price change',
            type: 'spline',
            yAxis: 1,
            data: changes,
            tooltip: {
                pointFormat: '<span style="color:{series.color}">\u25CF</span> Growth rate: {point.y:.1f} %'
            }
        }]
    }, function(chart){

            // apply the date pickers
            setTimeout(function () {
                $('input.highcharts-range-selector', $(chart.container).parent())
                .datepicker({startView: 1,minViewMode: 1,format: "yyyy-mm-dd",keyboardNavigation: true, autoclose: true});
            }, 0);
        });
        
    
  });

}
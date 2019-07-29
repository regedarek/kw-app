$(document).ready(function(){
  $.getJSON('/api/pogodynka', function (data) {
      // Create the chart
      Highcharts.stockChart('pogodynka-chart', {
          rangeSelector: {
              selected: 1
          },

          title: {
              text: 'Pogodynka'
          },

          series: [{
              name: 'Temperatura',
              data: data,
              tooltip: {
                  valueDecimals: 2
              }
          }]
      });
  });
});

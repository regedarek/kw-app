$(document).ready(function(){
  $.getJSON('http://localhost:3002/api/pogodynka', function (data) {
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

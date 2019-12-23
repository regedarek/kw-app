//= require jquery

$( document ).ready(function() {
    var API_URL = 'http://panel.kw.krakow.pl/api/pogodynka'
    var DAYS_COVERED = 5
    var scrapperData = {}

    function compare(a, b) {
        if (!a && !b) {
            return 0;
        }
        if (!a || !a.created_at) {
            return -1
        }
        if (!b || !b.created_at) {
            return 1
        }
        var dateA = new Date(a.created_at)
        var dateB = new Date(b.created_at)
        if (dateA.getTime() < dateB.getTime()) {
            return -1
        }
        if (dateA.getTime() > dateB.getTime()) {
            return 1
        }
        return 0
    }

    function fetchData() {
        $.ajax(API_URL)
            .fail(function() {
                alert( "Błąd przy pobieraniu danych " );
            })
            .done(function(response) {
                scrapperData = response
            })
    }

    function initListeners() {
        $("#place").on('change', function() {
            if (scrapperData[this.value]) {
                renderGraphs(scrapperData[this.value])
            } else {
                alert("Brak danych")
            }
          });          
    }

    function renderGraphs(data) {
        if (!data || !data.length) {
            return
        }
        data.sort(compare)
        var dataToShow = data.slice(-DAYS_COVERED)
        
        //temp
        renderTemp(dataToShow);
        renderSnow(dataToShow);
    }

    function renderTemp(data) {
        var gdata = new google.visualization.DataTable();

        gdata.addColumn('datetime', 'Data');
        gdata.addColumn('number', 'Temperatura');

        gdata.addRows(data.map(function (dataPoint) {
            return [new Date(dataPoint.created_at), dataPoint.temp]
        }));

        var chart = new google.visualization.LineChart(document.getElementById('temp'));
        var options = {
            title: 'Temperatura',
            curveType: 'function',
            legend: { position: 'bottom' }
          };
  
   
        chart.draw(gdata, options);
    }

    function renderSnow(data) {
        var gdata = new google.visualization.DataTable();

        gdata.addColumn('datetime', 'Data');
        gdata.addColumn('number', 'Całkowita grubość pokrywy śniegu cm');
        gdata.addColumn({type: 'string', role: 'annotation'});
        gdata.addColumn({type: 'string', role: 'annotationText'});

        gdata.addRows(data.map(function (dataPoint) {
            return [new Date(dataPoint.created_at), dataPoint.all_snow, dataPoint.snow_type_text, dataPoint.snow_type_text]
        }));

        var chart = new google.charts.Bar(document.getElementById('snow'));
        var options = {
            title: 'Śnieg',
            legend: { position: 'bottom' }
          };
  
   
        chart.draw(gdata, options);
    }

    function init() {
        fetchData();
        initListeners();
    }


    google.charts.load('current', {'packages':['corechart', 'bar']});
    google.charts.setOnLoadCallback(init);
});
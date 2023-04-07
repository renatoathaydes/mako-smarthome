<h2><?lsp= name ?></h2>
<div class='chart'>
    <canvas id='ctx-<?lsp= data.id ?>'></canvas>
</div>
<!-- Generated script to include chart.js chart -->
<script type='module'>
const ctx = document.getElementById('ctx-<?lsp= data.id ?>');
const data = <?lsp= ba.json.encode(data) ?>;
const weatherData = <?lsp= ba.json.encode(weatherData) ?>;
const weatherTimes = weatherData.times;
const weatherTemps = weatherData.temps;

let weatherIndex = 0;
const weatherChartData = data.times.map((time) => {
    // find the closest weather index at the given time
    let weatherTime = weatherTimes[weatherIndex];
    while (time > weatherTime && weatherIndex < weatherTimes.length - 1) {
        weatherIndex++;
        weatherTime = weatherTimes[weatherIndex];
    }
    return weatherTemps[weatherIndex];
});

new Chart(ctx, {
    type: 'line',
    data: {
      labels: data.times.map((t) => new Date(1000 * t).toLocaleString()),
      datasets: [{
        label: 'Temperature (C)',
        data: data.temps,
        fill: false,
        borderColor: 'rgb(75, 192, 192)',
        tension: 0.1
      }, {
        label: 'Outside Temp (C)',
        data: weatherChartData,
        fill: false,
        borderColor: 'red',
        tension: 0.1
      }]
    },
    options: {
        scales: {
            y: {
                beginAtZero: true
            }
        }
    }
});
</script>

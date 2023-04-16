<h2><?lsp= name ?></h2>
<div class='chart'>
    <canvas id='ctx-<?lsp= sensorData.id ?>'></canvas>
</div>
<!-- Generated script to include chart.js chart -->
<script type='module'>
const ctx = document.getElementById('ctx-<?lsp= sensorData.id ?>');
let sensorData = <?lsp= ba.json.encode(sensorData) ?>;
let weatherData = <?lsp= ba.json.encode(weatherData) ?>;
const dataLegend = '<?lsp= dataLegend ?>';

let times = new Set();
sensorData.times.forEach((t) => times.add(t));
weatherData.times.forEach((t) => times.add(t));
times = [...times].sort();

function adjustValues(ttimes, data) {
    const result = [];
    let index = 0;
    let nextIndex = 0;
    times.forEach((t) => {
        if (index < ttimes.length - 1 && ttimes[nextIndex] == t) {
            nextIndex++;
            if (nextIndex > 1) index++;
        }
        result.push(data[index]);
    });
    return result;
}

const sensorValues = adjustValues(sensorData.times, sensorData.values);
sensorData = null;
const weatherTemps = adjustValues(weatherData.times, weatherData.values);
weatherData = null;

new Chart(ctx, {
    type: 'line',
    data: {
      labels: [...times].map((t) => new Date(1000 * t).toLocaleString()),
      datasets: [{
        label: dataLegend,
        data: sensorValues,
        fill: false,
        borderColor: 'rgb(75, 192, 192)',
        tension: 0.1
      }, {
        label: 'Outside Temp (C)',
        data: weatherTemps,
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

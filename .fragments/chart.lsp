<h2><?lsp= name ?></h2>
<div class='chart'>
    <canvas id='ctx-<?lsp= sensorData.id ?>'></canvas>
</div>
<!-- Generated script to include chart.js chart -->
<script type='module'>
const ctx = document.getElementById('ctx-<?lsp= sensorData.id ?>');
let sensorData = <?lsp= ba.json.encode(sensorData) ?>;
let weatherData = <?lsp= ba.json.encode(#weatherData.times > 0 and weatherData or {}) ?>;
const dataLegend = '<?lsp= dataLegend ?>';

let times = new Set();
sensorData.times.forEach((t) => times.add(t));
if (weatherData.times) {
   weatherData.times.forEach((t) => times.add(t));
}
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

const dataSets = [{
    label: dataLegend,
    data: sensorValues,
    fill: false,
    borderColor: 'rgb(75, 192, 192)',
    tension: 0.1
}];

if (weatherData.times) {
    const weatherTemps = adjustValues(weatherData.times, weatherData.values);
    weatherData = null;
    dataSets.push({
       label: 'Outside Temp (C)',
        data: weatherTemps,
        fill: false,
        borderColor: 'red',
        tension: 0.1 
    });
}

new Chart(ctx, {
    type: 'line',
    data: {
      labels: [...times].map((t) => new Date(1000 * t).toLocaleString()),
      datasets: dataSets
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

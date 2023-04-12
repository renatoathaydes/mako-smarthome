function Lights(lightsData, webSocket) {
    for (const id in lightsData) {
        const light = lightsData[id];
        createLight(id, light, webSocket);
    }
    
    webSocket.addEventListener('message', (event) => {
        console.log('Got server message: ' + event.data);
        const message = JSON.parse(event.data);
        if (message.id != null) {
            if (message.type === 'changed' && message.state) {
                createOrUpdateLight(message.id, message.state, webSocket);
            } else if (message.type === 'deleted') {
                deleteLight(message.id);
            }
        } else if (message.error) {
            document.getElementById('error-message').innerText = message.error;
        } else if (message.ok) {
            document.getElementById('error-message').innerText = 'OK';
        }
    });
}

function updateLightState(light, data) {
    if (data.name) light.name = data.name;
    if (data.bri != null) light.bri = data.bri;
    if (data.on != null) light.on = data.on;
    if (data.reachable != null) light.reachable = data.reachable;
}

function createOrUpdateLight(id, data, webSocket) {
    const element = document.getElementById(id);
    if (element) {
        updateLightState(element.light, data);
        drawLight(element);
    } else {
        createLight(id, data, webSocket);
    }
}

// data schema: { name, on, bri, reachable, hascolor, type }
function createLight(id, data, webSocket) {
    const root = document.createElement('div');
    const nameSpan = document.createElement('span');
    const image = document.createElement('img');
    const slider = createLightSlider();
    root.id = id;
    root.light = data;
    root.classList.add('light');
    root.append(nameSpan, image, slider);

    image.classList.add('clickable');
    image.addEventListener('click', click => {
        webSocket.send(`{"id": "${id}", "r": "lights", "on": ${!root.light.on}}`);
        drawLight(root, nameSpan, image, slider);
    });
    slider.addEventListener('change', change => {
        webSocket.send(`{"id": "${id}", "r": "lights", "bri": ${1 * slider.value}}`);
    });
    
    drawLight(root, nameSpan, image, slider);

    const lights = document.getElementById('lights');
    lights.append(root);
}

function createLightSlider() {
    const root = document.createElement('input');
    root.classList.add('light-slider');
    root.type = 'range';
    root.min = 10;
    root.max = 254;
    root.step = 4;
    return root;
}

function drawLight(root, nameSpan, image, slider) {
    nameSpan = nameSpan || root.getElementsByTagName('span')[0];
    image = image || root.getElementsByTagName('img')[0];
    slider = slider || root.getElementsByTagName('input')[0];
    const data = root.light;
    if (data.on) {
        root.classList.add('light-on');
        image.src = '/smarthome/images/light-bulb-solid.svg';
    } else {
        root.classList.remove('light-on');
        image.src = '/smarthome/images/light-bulb.svg';
    }
    if (data.unreachable) {
        root.classList.add('unreachable');
    } else {
        root.classList.remove('unreachable');
    }
    if (data.bri != null) {
        slider.value = data.bri;
    }
    slider.disabled = data.bri == null || !data.on;
    nameSpan.innerText = data.name;
}

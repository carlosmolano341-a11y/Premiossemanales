<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tracker Diario - Managers Rebelde Live</title>
    <style>
        :root {
            --neon-pink: #ff007f;
            --neon-cyan: #00ffff;
            --neon-green: #39ff14;
            --bg-black: #0a0a0a;
            --panel-bg: #111111;
            --text-white: #ffffff;
        }
        body {
            background-color: var(--bg-black);
            color: var(--text-white);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px;
            margin: 0;
            display: flex;
            justify-content: center;
        }
        .container {
            width: 100%;
            max-width: 800px;
        }
        h2 { color: var(--neon-pink); text-align: center; text-transform: uppercase; }
        .manager-header {
            background: var(--panel-bg);
            padding: 20px;
            border-radius: 10px;
            border: 1px solid var(--neon-cyan);
            margin-bottom: 20px;
        }
        input[type="text"], input[type="number"] {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            background: #222;
            color: white;
            border: 1px solid #444;
            border-radius: 5px;
            box-sizing: border-box;
        }
        input:focus { outline: none; border-color: var(--neon-cyan); }
        .creator-card {
            background: #1a1a1a;
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid var(--neon-pink);
            margin-bottom: 15px;
            position: relative;
        }
        .grid-3 {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 10px;
            margin-top: 10px;
        }
        .checkbox-group {
            display: flex;
            gap: 15px;
            margin-top: 10px;
            font-size: 0.9em;
        }
        .progress-container {
            margin-top: 15px;
            background: #222;
            height: 12px;
            border-radius: 6px;
            overflow: hidden;
            position: relative;
        }
        .progress-bar {
            height: 100%;
            background: var(--neon-cyan);
            width: 0%;
            transition: width 0.3s;
        }
        .progress-bar.green { background: var(--neon-green); }
        .progress-bar.pink { background: var(--neon-pink); }
        .labels {
            display: flex;
            justify-content: space-between;
            font-size: 0.8em;
            color: #888;
            margin-top: 3px;
        }
        .payout-tag {
            background: rgba(57, 255, 20, 0.1);
            color: var(--neon-green);
            padding: 5px 10px;
            border-radius: 5px;
            font-weight: bold;
            display: inline-block;
            margin-top: 10px;
            border: 1px solid var(--neon-green);
        }
        .global-stats {
            background: var(--panel-bg);
            padding: 20px;
            border-radius: 10px;
            border: 2px solid var(--neon-green);
            margin-top: 20px;
            text-align: center;
        }
        .big-number { font-size: 2em; color: var(--neon-green); font-weight: bold; }
        button {
            width: 100%;
            padding: 15px;
            margin-top: 15px;
            background: var(--neon-pink);
            color: white;
            font-weight: bold;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-transform: uppercase;
        }
        button.add-btn { background: #333; border: 1px solid var(--neon-cyan); color: var(--neon-cyan); }
        button:hover { filter: brightness(1.2); }
    </style>
</head>
<body>

<div class="container">
    <h2>Rebelde Live - Operación Managers</h2>
    
    <div class="manager-header">
        <label>Nombre del Manager</label>
        <input type="text" id="managerName" placeholder="Ingresa tu nombre">
    </div>

    <div id="creatorsList"></div>

    <button class="add-btn" onclick="addCreator()">+ Agregar Nuevo Creador</button>

    <div class="global-stats">
        <h3 style="margin-top:0; color: var(--text-white);">PROGRESO GLOBAL DEL MANAGER</h3>
        <p>Conectividad del Grupo (Meta 75% para Bono 300k)</p>
        <div class="progress-container">
            <div id="globalConnBar" class="progress-bar pink" style="width: 0%;"></div>
        </div>
        <div class="labels">
            <span>0%</span>
            <span id="globalConnText">0%</span>
            <span>100%</span>
        </div>
        <br>
        <p>PROYECCIÓN DE PAGO ESTE MES</p>
        <div class="big-number" id="totalPayout">$0 COP</div>
    </div>

    <button onclick="sendToWhatsApp()">ENVIAR REPORTE A KAREN POR WHATSAPP</button>
</div>

<script>
    let creatorCount = 0;

    function addCreator() {
        creatorCount++;
        const div = document.createElement('div');
        div.className = 'creator-card';
        div.id = `creator-${creatorCount}`;
        div.innerHTML = `
            <input type="text" class="c-name" placeholder="Usuario de TikTok del Creador" oninput="calculate()">
            <div class="grid-3">
                <div>
                    <label style="font-size: 0.8em; color: #ccc;">Diamantes</label>
                    <input type="number" class="c-diamonds" placeholder="Ej. 40000" oninput="calculate()">
                </div>
                <div>
                    <label style="font-size: 0.8em; color: #ccc;">Días (Meta: 22)</label>
                    <input type="number" class="c-days" placeholder="0" oninput="calculate()">
                </div>
                <div>
                    <label style="font-size: 0.8em; color: #ccc;">Horas (Meta: 90)</label>
                    <input type="number" class="c-hours" placeholder="0" oninput="calculate()">
                </div>
            </div>
            <div class="checkbox-group">
                <label><input type="checkbox" class="c-msg"> Mensaje de seguimiento enviado hoy</label>
                <label><input type="checkbox" class="c-live"> Supervisión de Live realizada</label>
            </div>
            
            <div style="margin-top: 15px; font-size: 0.85em; color: var(--neon-cyan);">Progreso Diamantes</div>
            <div class="progress-container">
                <div class="progress-bar c-diamond-bar" style="width: 0%;"></div>
            </div>
            <div class="labels"><span>0</span><span>40k</span><span>80k</span><span>150k</span></div>

            <div class="payout-tag">Pago proyectado: $<span class="c-payout">0</span> COP</div>
        `;
        document.getElementById('creatorsList').appendChild(div);
        calculate();
    }

    function calculate() {
        const cards = document.querySelectorAll('.creator-card');
        let totalCreators = cards.length;
        let creatorsConnected = 0;
        let totalManagerPayout = 0;

        cards.forEach(card => {
            let diamonds = parseInt(card.querySelector('.c-diamonds').value) || 0;
            let days = parseInt(card.querySelector('.c-days').value) || 0;
            let hours = parseInt(card.querySelector('.c-hours').value) || 0;
            
            let payout = 0;
            let isConnected = (days >= 22 && hours >= 90);
            
            if (isConnected) creatorsConnected++;

            // Reglas de comisiones por diamantes y conectividad
            if (diamonds >= 150000) {
                payout += 200000;
                if (isConnected) payout += 50000; // Asumimos mismo bono de conectividad que en 80k
            } else if (diamonds >= 80000) {
                payout += 100000;
                if (isConnected) payout += 50000;
            } else if (diamonds >= 40000) {
                payout += 40000;
                if (isConnected) payout += 30000;
            }

            // Actualizar interfaz del creador
            card.querySelector('.c-payout').innerText = payout.toLocaleString('es-CO');
            
            // Barra de diamantes (Escala a 150k)
            let diamondPercent = Math.min((diamonds / 150000) * 100, 100);
            let dBar = card.querySelector('.c-diamond-bar');
            dBar.style.width = diamondPercent + '%';
            if(diamonds >= 80000) dBar.style.backgroundColor = 'var(--neon-green)';
            else if(diamonds >= 40000) dBar.style.backgroundColor = 'var(--neon-cyan)';
            else dBar.style.backgroundColor = '#555';

            totalManagerPayout += payout;
        });

        // Cálculos Globales
        let connPercent = totalCreators > 0 ? (creatorsConnected / totalCreators) * 100 : 0;
        document.getElementById('globalConnBar').style.width = connPercent + '%';
        document.getElementById('globalConnText').innerText = connPercent.toFixed(0) + '%';
        
        if (connPercent >= 75 && totalCreators > 0) {
            document.getElementById('globalConnBar').classList.add('green');
            totalManagerPayout += 300000; // Bono grupal
        } else {
            document.getElementById('globalConnBar').classList.remove('green');
        }

        document.getElementById('totalPayout').innerText = "$" + totalManagerPayout.toLocaleString('es-CO') + " COP";
    }

    function sendToWhatsApp() {
        const manager = document.getElementById('managerName').value || "Sin Nombre";
        const totalPayout = document.getElementById('totalPayout').innerText;
        const connPercent = document.getElementById('globalConnText').innerText;
        
        const cards = document.querySelectorAll('.creator-card');
        let report = `*REPORTE DIARIO MANAGER* 🚀%0A*Manager:* ${manager}%0A*Proyección de Pago:* ${totalPayout}%0A*Conectividad del Grupo:* ${connPercent}%0A%0A*DETALLE DE CREADORES:*%0A`;
        
        cards.forEach(card => {
            let name = card.querySelector('.c-name').value || "Desconocido";
            let diamonds = card.querySelector('.c-diamonds').value || 0;
            let days = card.querySelector('.c-days').value || 0;
            let hours = card.querySelector('.c-hours').value || 0;
            let msg = card.querySelector('.c-msg').checked ? "Sí" : "No";
            let live = card.querySelector('.c-live').checked ? "Sí" : "No";
            
            report += `👤 *${name}* | 💎 ${diamonds} | 📅 ${days}d | ⏱️ ${hours}h | Msg: ${msg} | Live: ${live}%0A`;
        });

        const url = `https://wa.me/573114835387?text=${report}`;
        window.open(url, '_blank');
    }

    // Inicializar con 1 creador por defecto
    addCreator();
</script>

</body>
</html>

#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install nginx
apt-get install -y nginx

# Create documentation HTML
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ZORK Documentation and Character Guide - Lab-X</title>
    <style>
        body {
            font-family: 'Georgia', serif;
            background-color: #1a1a1a;
            color: #e0e0e0;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
        }
        h1 {
            color: #ffcc00;
            text-align: center;
            border-bottom: 3px solid #ffcc00;
            padding-bottom: 10px;
        }
        h2 {
            color: #ffa500;
            margin-top: 30px;
            border-left: 4px solid #ffa500;
            padding-left: 15px;
        }
        .character {
            background-color: #2a2a2a;
            border: 1px solid #444;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        .character h3 {
            color: #ffcc00;
            margin-top: 0;
        }
        .traits {
            background-color: #1a1a1a;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .traits strong {
            color: #ffa500;
        }
        footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #444;
            color: #888;
        }
        a {
            color: #4a9eff;
        }
        .manual-embed {
            background-color: #2a2a2a;
            border: 1px solid #444;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        .manual-embed h3 {
            color: #ffcc00;
            margin-top: 0;
        }
        .manual-embed iframe {
            width: 100%;
            height: 480px;
            border: 1px solid #555;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <h1>🏰 ZORK Documentation and Character Guide 🏰</h1>
    
    <p style="text-align: center; font-style: italic; color: #aaa;">
        A guide to the inhabitants of the Great Underground Empire
    </p>

    <h2>📖 Official C64 Manual</h2>
    <div class="manual-embed">
        <h3>Zork I Manual — Internet Archive</h3>
        <iframe src="https://archive.org/embed/c64man_zork-1" allowfullscreen></iframe>
        <p style="color: #aaa; font-size: 13px; margin-bottom: 0;">
            Source: <a href="https://archive.org/details/c64man_zork-1" target="_blank">Internet Archive</a>
        </p>
    </div>

    <h2>👥 Character Guide</h2>

    <div class="character">
        <h3>🗡️ The Thief</h3>
        <p>
            The thief is one of the most dangerous and unpredictable adversaries in ZORK. 
            He roams the dungeon randomly, and if you encounter him, he may attack or steal 
            your valuable treasures.
        </p>
        <div class="traits">
            <p><strong>Behavior:</strong> Aggressive, opportunistic</p>
            <p><strong>Location:</strong> Randomly appears throughout the maze</p>
            <p><strong>Danger Level:</strong> High - can kill you or steal treasures</p>
            <p><strong>Strategy:</strong> Avoid confrontation when possible. If you must fight, 
            use the sword from the trophy case. He may drop items when defeated.</p>
        </div>
        <p>
            <strong>Fun Fact:</strong> The thief has his own treasure stash hidden somewhere 
            in the dungeon. Defeating him may reveal its location!
        </p>
    </div>

    <div class="character">
        <h3>👹 The Troll</h3>
        <p>
            A fearsome guardian blocking a critical passage in the dungeon. The troll stands 
            at the entrance to a bridge, preventing passage until dealt with properly.
        </p>
        <div class="traits">
            <p><strong>Behavior:</strong> Territorial, blocks bridge passage</p>
            <p><strong>Location:</strong> Guarding the bridge over the chasm</p>
            <p><strong>Danger Level:</strong> High - will kill you if you try to cross</p>
            <p><strong>Strategy:</strong> Combat is one option, but there are other creative 
            solutions. Consider what a troll might find valuable or distracting.</p>
        </div>
        <p>
            <strong>Fun Fact:</strong> Trolls in ZORK are not mindless brutes - they respond 
            to certain items in unexpected ways. Experimentation is key!
        </p>
    </div>

    <div class="character">
        <h3>👑 The Flatheads</h3>
        <p>
            The Flathead dynasty ruled the Great Underground Empire for centuries. Their 
            legacy is scattered throughout the dungeon in the form of treasures, monuments, 
            and historical artifacts.
        </p>
        <div class="traits">
            <p><strong>Historical Significance:</strong> Ancient rulers of the Empire</p>
            <p><strong>Notable Members:</strong></p>
            <ul>
                <li><strong>Lord Dimwit Flathead</strong> - Known for extravagant construction projects</li>
                <li><strong>King Mumberthrax</strong> - Builder of the Great Underground Highway</li>
                <li><strong>Wurb Flathead</strong> - The last king, mysterious disappearance</li>
            </ul>
            <p><strong>Related Locations:</strong> The Royal Treasury, Flathead Stadium, various monuments</p>
        </div>
        <p>
            <strong>Fun Fact:</strong> The Flatheads were known for their peculiar names and 
            ambitious (often impractical) construction projects. Their reign ended mysteriously 
            when the last king vanished, leaving the Empire in ruins.
        </p>
    </div>

    <h2>📚 Additional Information</h2>
    
    <div class="character">
        <h3>Character Interaction Tips</h3>
        <ul>
            <li><strong>Save often!</strong> Character encounters can be deadly</li>
            <li><strong>Experiment with items:</strong> Many characters respond to specific objects</li>
            <li><strong>Read everything:</strong> Historical texts provide clues about characters</li>
            <li><strong>Map encounters:</strong> Note where characters appear for future reference</li>
            <li><strong>Timing matters:</strong> Some characters move or appear at specific times</li>
        </ul>
    </div>

    <h2>🎮 Game Resources</h2>
    <div class="character">
        <ul>
            <li><a href="https://en.wikipedia.org/wiki/Zork" target="_blank">ZORK on Wikipedia</a></li>
            <li><a href="https://github.com/historicalsource/zork1" target="_blank">Original ZORK I Source Code (MIT Licensed)</a></li>
            <li><a href="https://github.com/the-infocom-files/zork1" target="_blank">ZORK I Compiled Game Files</a></li>
            <li><a href="https://github.com/curiousdannii/parchment" target="_blank">Parchment Z-Machine Interpreter</a></li>
        </ul>
    </div>

    <footer>
        <p><strong>Lab-X Documentation</strong></p>
        <p>Part of the Terraform Lab Series</p>
        <p>ZORK I is MIT Licensed | Parchment is MIT Licensed</p>
        <p>Created for educational purposes</p>
    </footer>
</body>
</html>
EOF

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Ensure nginx is running
systemctl enable nginx
systemctl restart nginx

# Create completion marker
touch /var/www/html/.setup-complete

echo "Documentation server setup complete!"

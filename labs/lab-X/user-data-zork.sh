#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install nginx and utilities
apt-get install -y nginx wget

# Create web directory
cd /var/www/html
rm -f index.nginx-debian.html

# Download MIT-licensed ZORK I (compiled game file)
# Primary: historicalsource/zork1 (has compiled files, master branch)
# Fallback: eblong.com (canonical Infocom game file archive)
echo "Downloading ZORK I game file..."
wget -O zork1.z3 https://raw.githubusercontent.com/historicalsource/zork1/master/COMPILED/zork1.z3 || \
wget -O zork1.z3 https://eblong.com/infocom/gamefiles/zork1-r119-s880429.z3

# Verify download succeeded
if [ ! -s zork1.z3 ]; then
    echo "FATAL: Failed to download zork1.z3 from all sources"
    exit 1
fi
echo "ZORK I game file downloaded successfully ($(stat -c%s zork1.z3) bytes)"

# Create index.html that loads ZORK with Parchment from iplayif.com CDN
# This is simpler and more reliable than downloading/building Parchment ourselves
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ZORK I: The Great Underground Empire</title>
    <style>
        * {
            box-sizing: border-box;
        }
        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: 'Courier New', monospace;
            background-color: #000;
            color: #0f0;
        }
        .header {
            background-color: #1a1a1a;
            padding: 10px;
            text-align: center;
            border-bottom: 2px solid #0f0;
        }
        h1 {
            margin: 0;
            color: #0f0;
            font-size: 24px;
        }
        .info {
            font-size: 12px;
            color: #888;
            margin-top: 5px;
        }
        #gameport {
            width: 100%;
            height: calc(100vh - 68px);
            border: none;
            display: block;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🏰 ZORK I: The Great Underground Empire 🏰</h1>
        <div class="info">Interactive Fiction Classic (1980) | MIT Licensed | Lab-X</div>
    </div>
    <!-- iplayif.com fetches zork1.z3 from this server via its built-in proxy -->
    <iframe id="gameport" title="ZORK I Game Terminal"></iframe>
    <script>
        var storyUrl = window.location.protocol + '//' + window.location.host + '/zork1.z3';
        document.getElementById('gameport').src = 'https://iplayif.com/?story=' + encodeURIComponent(storyUrl);
    </script>
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

echo "ZORK game server setup complete!"

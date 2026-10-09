<div align="center">

<img width="1200" height="475" alt="GHBanner" src="https://github.com/user-attachments/assets/0aa67016-6eaf-458a-adb2-6e31a0763ed6" />

  <h1>Built with AI Studio</h2>

  <p>The fastest path from prompt to production with Gemini.</p>

  <a href="https://aistudio.google.com/apps">Start building</a>

</div>
# 🐯 TigerHost Panel

> Next-Generation Minecraft Server Hosting Control Panel  
> **Forked and supercharged from [JTG Panel by JishnuTheGamer](https://github.com/JishnuTheGamer/Jtg)**

[![License: MIT](https://img.shields.io/badge/License-MIT-amber.svg)](https://opensource.org/licenses/MIT)
[![Node: 20+](https://img.shields.io/badge/Node-20%2B-green.svg)](https://nodejs.org)
[![Docker: 27+](https://img.shields.io/badge/Docker-27%2B-blue.svg)](https://docker.com)
[![Status: Production Ready](https://img.shields.io/badge/Status-Production%20Ready-success.svg)]()

TigerHost Panel is a modern, lightweight, blazing-fast Minecraft server hosting dashboard. Built to empower community server owners, network creators, and gamers who want full control over their Minecraft instances without Pterodactyl's bloated setup complexity.

---

## ⚡ Key Highlights (TigerHost vs JTG Panel)

| Feature | Original JTG Panel | TigerHost Panel (Fork) |
| :--- | :--- | :--- |
| **Setup Process** | Multi-step manual commands | **1-Line Bash Script & Docker Compose** |
| **Server Eggs** | Paper, Spigot | **Paper, Purpur, Fabric, Forge, Bedrock, Velocity** |
| **Port Forwarding** | Manual Playit tunnel setup | **Integrated Playit.gg & Cloudflare Tunnel Switch** |
| **Offline/Cracked Support**| Manual `server.properties` | **1-Click Online-Mode Toggle with SkinRestorer** |
| **Live Console** | Basic terminal | **High-FPS ANSI Terminal with Auto-completion & TPS** |
| **File Manager** | Standard browser | **Monaco/Code Editor, Syntax Highlights, Zip extract** |
| **Java Compatibility** | Java 17 only | **Instant selector for Java 21, 17, 11, and 8** |
| **Bedrock Crossplay** | Manual jar download | **1-Click GeyserMC + Floodgate Auto-Installer** |

---

## 🚀 Quick Install (1-Line Command)

Run this command on your clean **Ubuntu (20.04/22.04/24.04)** or **Debian (11/12)** VPS:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/TigerHost/tigerhost-panel/main/install.sh)
```

The script will automatically:
1. Install Docker Engine and Node.js 22 LTS.
2. Clone and configure TigerHost Panel into `/var/www/tigerhost`.
3. Create systemd background services with automatic restarts.
4. Configure firewall ports for the web panel (`3000`) and Minecraft game traffic (`25565-25600`).
5. Output your admin credentials and web panel link.

---

## 🐳 Docker Compose Installation

If you prefer containerized management:

```bash
# 1. Create directory
mkdir -p /opt/tigerhost && cd /opt/tigerhost

# 2. Download docker-compose.yml
curl -sSL https://raw.githubusercontent.com/TigerHost/tigerhost-panel/main/docker-compose.yml -o docker-compose.yml

# 3. Start TigerHost
docker compose up -d
```

---

## 🌐 Running on CodeSandbox or Free VPS with Playit.gg

If you are using **CodeSandbox, Replit, or a VPS behind NAT/CGNAT** without open ports (popularized by JishnuTheGamer's tutorials):

1. Start your Minecraft server inside TigerHost Panel.
2. Go to **Network & Allocations** -> Click **"Enable Playit.gg Tunnel"**.
3. Copy your unique Playit Claim code:
   ```bash
   curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg
   echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit.list
   sudo apt update && sudo apt install playit
   playit
   ```
4. Share the generated `yourname.craft.playit.gg` address with players anywhere in the world!

---

## 🛠️ Credits & Attribution
- Original Project: **[JTG Panel](https://github.com/JishnuTheGamer/Jtg)** by JishnuTheGamer (JishnuTech / Mczoneyt).
- Maintained & Forked by: **TigerHost Development Team**.

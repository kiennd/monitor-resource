# Resource Monitoring Script

This script monitors the CPU, RAM, and disk usage of a server and sends alerts via Telegram based on configurable thresholds. It computes the average CPU usage over three consecutive readings for greater accuracy and sends notifications when resource usage exceeds warning and critical levels. Additionally, it notifies when usage returns to normal.

## Features

- **Monitors CPU, RAM, and Disk Usage**: Continuously monitors system resources at regular intervals.
- **Threshold Alerts**: Sends alerts for two levels of resource usage:
  - **Warning**: When CPU, RAM, or disk usage exceeds a warning threshold (e.g., 80%).
  - **Agent (Critical)**: When CPU, RAM, or disk usage exceeds a critical threshold (e.g., 90%).
- **Telegram Alerts**: Sends alerts to a specified Telegram group using the Telegram Bot API.
- **Recovery Notifications**: Notifies when the resource usage returns to normal.
- **Customizable Alert Messages**: Includes symbols to indicate warning (`⚠️`), critical alerts (`🔴`), and good status (`✅`).

## Requirements

- **Bash**
- `top`, `free`, `df` (available on most Unix-based systems)
- `curl` for sending Telegram messages
- A Telegram bot token and group chat ID

## Setup

### 1. Clone or Download the Repository

```bash
git clone https://github.com/kiennd/monitor-resource.git
cd resource-monitor-script
```

### 2. Create a `.env` File

Create a `.env` file in the root of the project directory with the following content:

```bash
# .env file

# Server name for identification (optional, will use hostname if not set)
SERVER_NAME="MyServer"

# Telegram Bot API token (from BotFather)
TELEGRAM_BOT_TOKEN="your-telegram-bot-token"

# Telegram Group Chat ID (make sure it's correct, with - for groups)
TELEGRAM_GROUP_CHAT_ID="-1001234567890"

# Warning and Agent (Critical) thresholds for CPU, RAM, and Disk
CPU_THRESHOLD_WARNING=80
CPU_THRESHOLD_AGENT=90
RAM_THRESHOLD_WARNING=80
RAM_THRESHOLD_AGENT=90
DISK_THRESHOLD_WARNING=80
DISK_THRESHOLD_AGENT=90

# Alert message format
# Available placeholders: {resource}, {usage}, {mention}, {server}
WARNING_MESSAGE_FORMAT="⚠️ Warning: {resource} usage is at {usage}% on {server}. {mention}"
AGENT_MESSAGE_FORMAT="🔴 Agent Alert: {resource} usage is at {usage}% on {server}. Immediate attention required! {mention}"
GOOD_MESSAGE_FORMAT="✅ {resource} usage is back to normal on {server}. {mention}"

# Telegram user mentions (optional)
ALERT_MENTION="@user1 @user2 @user3"
```

### 3. Set Up and Run the Monitoring Script

Make the script executable and run it.

```bash
chmod +x monitor_resources.sh
./monitor_resources.sh
```

### Monitoring Thresholds

You can customize the thresholds in the `.env` file for CPU, RAM, and disk usage:

- **Warning Threshold**: When usage exceeds this percentage, a warning is sent.
- **Agent (Critical) Threshold**: When usage exceeds this percentage, a critical alert is sent.

### Example Alerts

- **Warning Message**:
  ```
  ⚠️ Warning: CPU usage is at 85% on MyServer. @user1 @user2 @user3
  ```

- **Agent Alert Message**:
  ```
  🔴 Agent Alert: RAM usage is at 95% on MyServer. Immediate attention required! @user1 @user2 @user3
  ```

- **Good Status Message**:
  ```
  ✅ Disk usage is back to normal on MyServer. @user1 @user2 @user3
  ```

### Project Structure

```
/project-root
│
├── .env                 # Environment configuration
├── monitor_resources.sh  # Resource monitoring script
└── README.md            # Project documentation
```

## License

This project is licensed under the MIT License.

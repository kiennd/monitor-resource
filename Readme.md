# Resource Monitoring Script

This project contains a script that monitors CPU, RAM, and disk usage on the current machine and sends alerts to a Telegram group if the usage exceeds specified thresholds. There are two levels of alerts: `Warning` and `Agent`, based on the severity of the resource usage.

## Features

- **Monitors CPU, RAM, and Disk Usage**: Continuously monitors system resource usage.
- **Alerts via Telegram**: Sends alerts to a Telegram group when resource usage exceeds warning and critical (agent) thresholds.
- **Recovery Notifications**: Sends a notification when resource usage returns to normal after a warning or agent alert.
- **Customizable Thresholds**: You can configure usage thresholds for warnings and agent alerts.
- **Customizable Messages**: Allows you to customize the alert messages, including mentioning multiple users.

## Requirements

- Bash
- `curl` (pre-installed on most Unix-based systems)
- Docker and Docker Compose (optional, if containerizing the script)
- Telegram Bot API token and Group Chat ID

## Setup

### 1. Clone or Download the Repository

```bash
git clone https://github.com/your-repo/resource-monitor-script.git
cd resource-monitor-script
```

### 2. Create a `.env` File

Create a `.env` file in the root of the project directory with the following content:

```bash
# .env file

# Telegram Bot API token
TELEGRAM_BOT_TOKEN="your-telegram-bot-token"

# Telegram Group Chat ID
TELEGRAM_GROUP_CHAT_ID="-4081396404"

# Warning and Agent thresholds
CPU_THRESHOLD_WARNING=80
CPU_THRESHOLD_AGENT=90
RAM_THRESHOLD_WARNING=80
RAM_THRESHOLD_AGENT=90
DISK_THRESHOLD_WARNING=80
DISK_THRESHOLD_AGENT=90

# Alert message format
# Available placeholders: {resource}, {usage}, {level}, {mention}
WARNING_MESSAGE_FORMAT="Warning: {resource} usage is at {usage}%. {mention}"
AGENT_MESSAGE_FORMAT="Agent Alert: {resource} usage is at {usage}%. Immediate attention required! {mention}"
GOOD_MESSAGE_FORMAT="{resource} usage is back to normal. {mention}"

# Multiple mentions
ALERT_MENTION="@user1 @user2 @user3"
```

In this example:
- **TELEGRAM_BOT_TOKEN**: Your Telegram bot token.
- **TELEGRAM_GROUP_CHAT_ID**: The ID of your Telegram group where alerts will be sent.
- **ALERT_MENTION**: The Telegram usernames of the people to mention in the alert.

### 3. Run the Monitoring Script

You can run the script directly on your machine.

1. Make the script executable:

   ```bash
   chmod +x monitor_resources.sh
   ```

2. Run the script:

   ```bash
   ./monitor_resources.sh
   ```

The script will continuously monitor the system resources and send alerts to the Telegram group if the resource usage exceeds the defined thresholds.

### 4. Run the Script in a Docker Container (Optional)

You can run the script inside a Docker container. Here’s how to set up and run it using Docker and Docker Compose.

#### 1. Build the Docker Image

```bash
docker-compose build
```

#### 2. Run the Container

```bash
docker-compose up -d
```

This will start the container in detached mode, and it will continuously monitor the system resources inside the container.

### Monitoring Thresholds

- **Warning**: When CPU, RAM, or disk usage exceeds 80% (or any other threshold defined in the `.env` file).
- **Agent Alert**: When CPU, RAM, or disk usage exceeds 90% (or any other critical threshold defined in the `.env` file).
- **Good Alert**: When usage falls back below the warning threshold after a warning or agent alert.

## Example Alerts

- **Warning Message**:

  ```
  Warning: CPU usage is at 85%. @user1 @user2 @user3
  ```

- **Agent Alert Message**:

  ```
  Agent Alert: Disk usage is at 95%. Immediate attention required! @user1 @user2 @user3
  ```

- **Good Alert Message**:

  ```
  CPU usage is back to normal. @user1 @user2 @user3
  ```

## Project Structure

Your project should look like this:

```
/project-root
│
├── .env
├── Dockerfile
├── docker-compose.yml
└── monitor_resources.sh
```

- **.env**: Holds environment variables like Telegram API tokens and resource thresholds.
- **Dockerfile**: Used to containerize the monitoring script.
- **docker-compose.yml**: Automates building and running the container using Docker Compose.
- **monitor_resources.sh**: The Bash script that monitors the system resources and sends alerts.

## License

This project is licensed under the MIT License.

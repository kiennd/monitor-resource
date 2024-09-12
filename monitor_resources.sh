#!/bin/bash

# Function to get CPU usage
get_cpu_usage() {
  # Get the average CPU usage over the last 1 minute
  top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}'
}

# Function to get RAM usage
get_ram_usage() {
  free | grep Mem | awk '{print $3/$2 * 100.0}'
}

# Function to get disk usage for root (/)
get_disk_usage() {
  df / | tail -1 | awk '{print $5}' | sed 's/%//'
}

# Function to send an alert message to Telegram
send_alert() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
  -d chat_id="$TELEGRAM_GROUP_CHAT_ID" \
  -d text="$message"
}

# State variables to track if the system was previously in warning or agent state
cpu_warning_sent=false
cpu_agent_sent=false
ram_warning_sent=false
ram_agent_sent=false
disk_warning_sent=false
disk_agent_sent=false

# Infinite loop to monitor the system resources
while true; do
  cpu_usage=$(get_cpu_usage)
  ram_usage=$(get_ram_usage)
  disk_usage=$(get_disk_usage)

  # Check CPU usage
  if (( $(echo "$cpu_usage > $CPU_THRESHOLD_AGENT" | bc -l) )); then
    if [ "$cpu_agent_sent" = false ]; then
      message=$(echo "$AGENT_MESSAGE_FORMAT" | sed "s|{resource}|CPU|g" | sed "s|{usage}|$cpu_usage|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      cpu_agent_sent=true
    fi
  elif (( $(echo "$cpu_usage > $CPU_THRESHOLD_WARNING" | bc -l) )); then
    if [ "$cpu_warning_sent" = false ]; then
      message=$(echo "$WARNING_MESSAGE_FORMAT" | sed "s|{resource}|CPU|g" | sed "s|{usage}|$cpu_usage|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      cpu_warning_sent=true
    fi
    cpu_agent_sent=false
  else
    if [ "$cpu_warning_sent" = true ] || [ "$cpu_agent_sent" = true ]; then
      message=$(echo "$GOOD_MESSAGE_FORMAT" | sed "s|{resource}|CPU|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      cpu_warning_sent=false
      cpu_agent_sent=false
    fi
  fi

  # Check RAM usage
  if (( $(echo "$ram_usage > $RAM_THRESHOLD_AGENT" | bc -l) )); then
    if [ "$ram_agent_sent" = false ]; then
      message=$(echo "$AGENT_MESSAGE_FORMAT" | sed "s|{resource}|RAM|g" | sed "s|{usage}|$ram_usage|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      ram_agent_sent=true
    fi
  elif (( $(echo "$ram_usage > $RAM_THRESHOLD_WARNING" | bc -l) )); then
    if [ "$ram_warning_sent" = false ]; then
      message=$(echo "$WARNING_MESSAGE_FORMAT" | sed "s|{resource}|RAM|g" | sed "s|{usage}|$ram_usage|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      ram_warning_sent=true
    fi
    ram_agent_sent=false
  else
    if [ "$ram_warning_sent" = true ] || [ "$ram_agent_sent" = true ]; then
      message=$(echo "$GOOD_MESSAGE_FORMAT" | sed "s|{resource}|RAM|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      ram_warning_sent=false
      ram_agent_sent=false
    fi
  fi

  # Check Disk usage
  if (( $(echo "$disk_usage > $DISK_THRESHOLD_AGENT" | bc -l) )); then
    if [ "$disk_agent_sent" = false ]; then
      message=$(echo "$AGENT_MESSAGE_FORMAT" | sed "s|{resource}|Disk|g" | sed "s|{usage}|$disk_usage|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      disk_agent_sent=true
    fi
  elif (( $(echo "$disk_usage > $DISK_THRESHOLD_WARNING" | bc -l) )); then
    if [ "$disk_warning_sent" = false ]; then
      message=$(echo "$WARNING_MESSAGE_FORMAT" | sed "s|{resource}|Disk|g" | sed "s|{usage}|$disk_usage|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      disk_warning_sent=true
    fi
    disk_agent_sent=false
  else
    if [ "$disk_warning_sent" = true ] || [ "$disk_agent_sent" = true ]; then
      message=$(echo "$GOOD_MESSAGE_FORMAT" | sed "s|{resource}|Disk|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      disk_warning_sent=false
      disk_agent_sent=false
    fi
  fi

  # Sleep for 60 seconds before the next check
  sleep 60
done

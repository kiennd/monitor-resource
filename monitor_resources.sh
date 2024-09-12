#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Function to get CPU usage
get_cpu_usage() {
  total=0
  
  # Call 'top' 3 times, sum the CPU idle percentages, and calculate the average CPU usage
  for i in {1..3}; do
    # Extract the CPU idle percentage and calculate usage (reliable extraction method)
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    total=$(echo "$total + $cpu_idle" | bc)
    
    # Sleep for a short while between measurements to avoid immediate consecutive calls
    sleep 1
  done

  # Calculate average CPU usage
  avg_cpu_usage=$(echo "$total / 3" | bc -l)

  # Return the average CPU usage
  echo "$avg_cpu_usage"
}

# Function to get RAM usage
get_ram_usage() {
  free | grep Mem | awk '{print $3/$2 * 100.0}'
}

# Function to get disk usage for root (/)
get_disk_usage() {
  df / | tail -1 | awk '{print $5}' | sed 's/%//'
}

# Function to check if a value is numeric
is_numeric() {
  local value="$1"
  [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]
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

  # Log the retrieved values for debugging
  echo "CPU Usage: $cpu_usage"
  echo "RAM Usage: $ram_usage"
  echo "Disk Usage: $disk_usage"

  # Ensure the values are numeric before proceeding
  if ! is_numeric "$cpu_usage"; then
    echo "Invalid CPU usage: $cpu_usage"
    cpu_usage=0
  fi
  if ! is_numeric "$ram_usage"; then
    echo "Invalid RAM usage: $ram_usage"
    ram_usage=0
  fi
  if ! is_numeric "$disk_usage"; then
    echo "Invalid Disk usage: $disk_usage"
    disk_usage=0
  fi

  # Ensure the values have a decimal point for bc to process correctly
  cpu_usage=$(printf "%.1f" "$cpu_usage")
  ram_usage=$(printf "%.1f" "$ram_usage")
  disk_usage=$(printf "%.1f" "$disk_usage")

  #########################
  # CPU usage check
  #########################
  if (( $(echo "$cpu_usage > $CPU_THRESHOLD_AGENT" | bc -l) )); then
    if [ "$cpu_agent_sent" = false ]; then
      message=$(echo "$AGENT_MESSAGE_FORMAT" | sed "s|{resource}|CPU|g" | sed "s|{usage}|$cpu_usage|g" | sed "s|{server}|$SERVER_NAME|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      cpu_agent_sent=true
    fi
  elif (( $(echo "$cpu_usage > $CPU_THRESHOLD_WARNING" | bc -l) )); then
    if [ "$cpu_warning_sent" = false ]; then
      message=$(echo "$WARNING_MESSAGE_FORMAT" | sed "s|{resource}|CPU|g" | sed "s|{usage}|$cpu_usage|g" | sed "s|{server}|$SERVER_NAME|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      cpu_warning_sent=true
    fi
    cpu_agent_sent=false
  else
    if [ "$cpu_warning_sent" = true ] || [ "$cpu_agent_sent" = true ]; then
      message=$(echo "$GOOD_MESSAGE_FORMAT" | sed "s|{resource}|CPU|g" | sed "s|{server}|$SERVER_NAME|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      cpu_warning_sent=false
      cpu_agent_sent=false
    fi
  fi

  #########################
  # RAM usage check
  #########################
  if (( $(echo "$ram_usage > $RAM_THRESHOLD_AGENT" | bc -l) )); then
    if [ "$ram_agent_sent" = false ]; then
      message=$(echo "$AGENT_MESSAGE_FORMAT" | sed "s|{resource}|RAM|g" | sed "s|{usage}|$ram_usage|g" | sed "s|{server}|$SERVER_NAME|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      ram_agent_sent=true
    fi
  elif (( $(echo "$ram_usage > $RAM_THRESHOLD_WARNING" | bc -l) )); then
    if [ "$ram_warning_sent" = false ]; then
      message=$(echo "$WARNING_MESSAGE_FORMAT" | sed "s|{resource}|RAM|g" | sed "s|{usage}|$ram_usage|g" | sed "s|{server}|$SERVER_NAME|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      ram_warning_sent=true
    fi
    ram_agent_sent=false
  else
    if [ "$ram_warning_sent" = true ] || [ "$ram_agent_sent" = true ]; then
      message=$(echo "$GOOD_MESSAGE_FORMAT" | sed "s|{resource}|RAM|g" | sed "s|{server}|$SERVER_NAME|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      ram_warning_sent=false
      ram_agent_sent=false
    fi
  fi

  #########################
  # Disk usage check
  #########################
  if (( $(echo "$disk_usage > $DISK_THRESHOLD_AGENT" | bc -l) )); then
    if [ "$disk_agent_sent" = false ]; then
      message=$(echo "$AGENT_MESSAGE_FORMAT" | sed "s|{resource}|Disk|g" | sed "s|{usage}|$disk_usage|g" | sed "s|{server}|$SERVER_NAME|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      disk_agent_sent=true
    fi
  elif (( $(echo "$disk_usage > $DISK_THRESHOLD_WARNING" | bc -l) )); then
    if [ "$disk_warning_sent" = false ]; then
      message=$(echo "$WARNING_MESSAGE_FORMAT" | sed "s|{resource}|Disk|g" | sed "s|{usage}|$disk_usage|g" | sed "s|{server}|$SERVER_NAME|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      disk_warning_sent=true
    fi
    disk_agent_sent=false
  else
    if [ "$disk_warning_sent" = true ] || [ "$disk_agent_sent" = true ]; then
      message=$(echo "$GOOD_MESSAGE_FORMAT" | sed "s|{resource}|Disk|g" | sed "s|{server}|$SERVER_NAME|g" | sed "s|{mention}|$ALERT_MENTION|g")
      send_alert "$message"
      disk_warning_sent=false
      disk_agent_sent=false
    fi
  fi

  # Sleep for 60 seconds before the next check
  sleep 10
done

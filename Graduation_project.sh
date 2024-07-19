#!/bin/bash
LogParsing() {  

logfile=$1
echo "-----Log Parsing-----"
while IFS= read -r line; do
    # Extract timestamp
    timestamp=$(echo "$line" | awk -F '[][]' '{print $2}')

    # Extract log level
    loglevel=$(echo "$line" | awk '{print $3}')

    # Extract message
   message=$(echo "$line" | awk '{$1=$2=$3=""; print substr($0, 4)}')
    
    echo "Timestamp: $timestamp | Level: $loglevel | Message: $message"
done < $logfile
Options "$logfile"
}

function Filtering () {
    echo "-----Filtering-----"
 # Ask user for log levels to filter
echo "Enter log levels to filter (ERROR WARN INFO DEBUG) separated by spaces :"
read -a filter_levels
declare -A matched_levels
while IFS= read -r line; do

    # Extract log level
    loglevel=$(echo "$line" | awk '{print $3}')
   for filter in "${filter_levels[@]}"; do
            if [[ "${loglevel}" == "${filter}" ]]; then
                echo "$line"
                matched_levels[$filter]=1
                break  # Break out of the loop once a match is found
            fi
        done
done < $1
    for filter in "${filter_levels[@]}"; do
            if [[ ! "${matched_levels[$filter]}" ]]; then
                echo "No $filter found"
    
            fi
        done
Options "$1"
}
function ErrorAndWarningSummary() {
     echo "-----Errors and Warnings Summary-----"
    ERROR="ERROR"
    WARN="WARN"
    declare -A error_details
    declare -A warn_details
    error_count=0
    warn_count=0

    while IFS= read -r line; do
        # Extract log level
        loglevel=$(echo "$line" | awk '{print $3}')
        if [[ "${loglevel}" == "${ERROR}" ]]; then
            ((error_count++))
            error_details[$error_count]=$line
        elif [[ "${loglevel}" == "${WARN}" ]]; then
            ((warn_count++))
            warn_details[$warn_count]=$line
        fi
    done < $1

print_summary "$ERROR" "$error_count" error_details
print_summary "$WARN" "$warn_count" warn_details
Options "$1"
}
function EventTracking () {
    echo "-----Event Tracking-----"
    echo "Enter events to track line by line. Press Ctrl+D when finished :"
    read -a event_tracking
    declare -A matched_events
    # Read events input into an array
    while IFS= read -r event; do
        event_tracking+=("$event")
    done

    while IFS= read -r line; do
        # Extract message 
        message=$(awk '{$1=$2=$3=""; print substr($0, 4)}' <<< "$line") 
        # Check if the message contains any event in event_tracking array
        for event in "${event_tracking[@]}"; do
            if [[ "${message}" == *"${event}"* ]]; then
                echo "$event event is completed :"
                echo "$line"
                matched_events[$event]=1
                break  # Break out of the loop once a match is found
        fi
        done
    done < $1

    # Check for events that are not matched
    for event in "${event_tracking[@]}"; do
        if [[ ! "${matched_events[$event]}" ]]; then
            echo "$event event is not matched (not found)"
        fi
    done
    Options "$1"
}
function ReportGeneration() {
    echo "-----Report Generation-----"
    ERROR="ERROR"
    WARN="WARN"
    INFO="INFO"
    DEBUG="DEBUG"
    
    declare -A error_details
    declare -A warn_details
    declare -A info_details
    declare -A debug_details
    
    error_count=0
    warn_count=0
    info_count=0
    debug_count=0
    
    while IFS= read -r line; do
        # Extract log level
        loglevel=$(echo "$line" | awk '{print $3}')
        
        case $loglevel in
            "$ERROR")
                ((error_count++))
                error_details[$error_count]="$line"
                ;;
            "$WARN")
                ((warn_count++))
                warn_details[$warn_count]="$line"
                ;;
            "$INFO")
                ((info_count++))
                info_details[$info_count]="$line"
                ;;
            "$DEBUG")
                ((debug_count++))
                debug_details[$debug_count]="$line"
                ;;
            *)
                ;;
        esac
    done < $1
    
    # Call print_summary function for each log level
    print_summary "$ERROR" "$error_count" error_details
    print_summary "$WARN"  "$warn_count" warn_details
    print_summary "$INFO"   "$info_count" info_details
    print_summary "$DEBUG"  "$debug_count" debug_details
    Options "$1"
}
 print_summary() {
         # Print summary and details for each log level
         loglevel=$1
         loglevel_count=$2
         declare -n loglevel_details=$3
 
        if ((loglevel_count !=0)); then
            echo "Number of $loglevel = $loglevel_count"
            echo "Details of $loglevel:"
            for (( i=1; i<=loglevel_count; i++ )); do
     # Extract timestamp
    timestamp=$(echo "${loglevel_details[$i]}" | awk -F '[][]' '{print $2}')
     # Extract log level
    loglevel=$(echo "${loglevel_details[$i]}" | awk '{print $3}')
     # Extract message
   message=$(echo "${loglevel_details[$i]}" | awk '{$1=$2=$3=""; print substr($0, 4)}')
    echo "Timestamp: $timestamp | Level: $loglevel | Message: $message" 
            done
        else
            echo "No $loglevel found"
        fi
    }
function Options () {
 if [ ! -f "$1" ]; then
    echo "File \"$1\"\doesn't exist"
    exit 
 fi
    echo "Enter the number of Operation :"
    echo "1-Log Parsing"
    echo "2-Filtering"
    echo "3-Error and Warning Summary"
    echo "4-Event Tracking"
    echo "5-Report Generation"
    read option

    case "${option}" in
        1)
           LogParsing "$1"
        ;;
        2)
            Filtering "$1"
        ;;
         3)
            ErrorAndWarningSummary "$1"
        ;;
         4)
            EventTracking "$1"
        ;;
         5)
            ReportGeneration "$1"
        ;;
        *)
            echo "Invalid number"
        ;;
    esac
    
}
Options "$1"
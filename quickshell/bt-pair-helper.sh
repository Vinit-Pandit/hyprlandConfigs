#!/bin/bash
# Bluetooth Pairing Helper Script
# Uses expect to intercept passkey prompts and communicate with QML

MAC=$1
TIMEOUT=30

# Clean up old files
rm -f /tmp/bt-passkey /tmp/bt-response /tmp/bt-status

echo "[BT HELPER] Starting pairing for MAC: $MAC" >&2

# Use expect to handle interactive pairing
expect -c "
set timeout $TIMEOUT
set mac \"$MAC\"

spawn bluetoothctl

expect \"#\" {
    send \"pair \$mac\r\"
}

# Wait for either passkey prompt or error
expect {
    \"Attempting to pair with\" {
        # Good - pairing attempt started
        exp_continue
    }
    \"Confirm passkey\" {
        # Extract the passkey number
        regexp {Confirm passkey (\d+)} \$expect_out(buffer) -> passkey
        
        # Write passkey to file so QML can read it
        set fp [open \"/tmp/bt-passkey\" w]
        puts \$fp \$passkey
        close \$fp
        
        # Wait for user response (max 30 seconds)
        set start_time [clock seconds]
        while { 1 } {
            if { [file exists \"/tmp/bt-response\"] } {
                # Read the response
                set fp [open \"/tmp/bt-response\" r]
                set response [gets \$fp]
                close \$fp
                
                # Send it to bluetoothctl
                send \"\$response\r\"
                
                # Clean up response file
                file delete \"/tmp/bt-response\"
                break
            }
            
            # Timeout after 30 seconds
            if { [expr {[clock seconds] - \$start_time}] > $TIMEOUT } {
                send \"quit\r\"
                puts \"[BT HELPER] Timeout waiting for user response\" >&2
                exit 1
            }
            
            after 100
        }
        
        exp_continue
    }
    \"Device already exists\" {
        puts \"[BT HELPER] Device already paired\" >&2
        send \"quit\r\"
        exit 0
    }
    \"not available\" {
        puts \"[BT HELPER] Device not available\" >&2
        send \"quit\r\"
        exit 1
    }
    \"#\" {
        send \"quit\r\"
    }
}

expect \"#\" {
    send \"quit\r\"
}

expect eof {
    puts \"[BT HELPER] Pairing process completed\" >&2
}
" 2>&1

# Clean up
rm -f /tmp/bt-passkey /tmp/bt-response

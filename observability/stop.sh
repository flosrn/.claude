#!/bin/bash

echo "🛑 Stopping Claude Code Multi-Agent Observability"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Read PIDs if they exist
PIDS_FILE="$SCRIPT_DIR/.pids"
if [ -f "$PIDS_FILE" ]; then
    read SERVER_PID CLIENT_PID < "$PIDS_FILE"
    
    echo -e "${YELLOW}Stopping processes...${NC}"
    
    if [ ! -z "$SERVER_PID" ]; then
        kill $SERVER_PID 2>/dev/null && echo -e "✅ Server stopped (PID: $SERVER_PID)"
    fi
    
    if [ ! -z "$CLIENT_PID" ]; then
        kill $CLIENT_PID 2>/dev/null && echo -e "✅ Client stopped (PID: $CLIENT_PID)"
    fi
    
    rm -f "$PIDS_FILE"
else
    echo -e "${YELLOW}No PID file found, attempting to kill by port...${NC}"
    
    # Kill processes by port
    SERVER_PIDS=$(lsof -ti:4000)
    CLIENT_PIDS=$(lsof -ti:5173)
    
    if [ ! -z "$SERVER_PIDS" ]; then
        echo $SERVER_PIDS | xargs kill 2>/dev/null && echo -e "✅ Killed processes on port 4000"
    fi
    
    if [ ! -z "$CLIENT_PIDS" ]; then
        echo $CLIENT_PIDS | xargs kill 2>/dev/null && echo -e "✅ Killed processes on port 5173"
    fi
fi

echo -e "${GREEN}✅ Observability system stopped${NC}"
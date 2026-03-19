#!/bin/bash
# CareSphere AI - Complete Testing Setup
# This script will set up and run the complete end-to-end test

echo "================================"
echo "CareSphere AI - Testing Setup"
echo "================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Backend Setup
echo -e "${BLUE}[Step 1] Setting up Backend...${NC}"
cd backend
echo "Installing Python dependencies..."
pip install -r requirements.txt
echo -e "${GREEN}✓ Backend dependencies installed${NC}"
echo ""

# Step 2: Start Backend
echo -e "${BLUE}[Step 2] Starting Backend Server...${NC}"
echo "Backend will run on: http://localhost:5000"
python app.py &
BACKEND_PID=$!
echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
echo "Waiting 3 seconds for backend to initialize..."
sleep 3
echo ""

# Step 3: Frontend Setup
echo -e "${BLUE}[Step 3] Setting up Frontend...${NC}"
cd ../frontend/caresphere
echo "Installing Flutter dependencies..."
flutter pub get
echo -e "${GREEN}✓ Flutter dependencies installed${NC}"
echo ""

# Step 4: Run Frontend
echo -e "${BLUE}[Step 4] Starting Flutter App...${NC}"
echo "Running on: Android Emulator / iOS Simulator / Web"
flutter run
echo ""

# Cleanup
echo -e "${YELLOW}Cleaning up...${NC}"
kill $BACKEND_PID
echo -e "${GREEN}Testing completed${NC}"

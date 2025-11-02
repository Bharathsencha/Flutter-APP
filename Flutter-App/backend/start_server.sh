#!/bin/bash

echo "================================================"
echo "Video Downloader Backend Setup"
echo "================================================"
echo ""

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to create virtual environment"
        echo "Make sure Python 3 is installed"
        exit 1
    fi
    echo "Virtual environment created successfully!"
    echo ""
fi

echo "Activating virtual environment..."
source venv/bin/activate

echo ""
echo "Installing dependencies..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install dependencies"
    exit 1
fi

echo ""
echo "================================================"
echo "Setup completed successfully!"
echo "================================================"
echo ""
echo "Starting Flask server..."
echo "Server will be available at http://localhost:5000"
echo ""
echo "Press Ctrl+C to stop the server"
echo "================================================"
echo ""

python app.py

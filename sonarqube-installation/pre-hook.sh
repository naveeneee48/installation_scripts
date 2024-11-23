#!/bin/bash
echo "Running SonarScanner before push..."
/opt/sonar-scanner/bin/sonar-scanner
if [ $? -ne 0 ]; then
    echo "SonarScanner failed. Aborting push!"
    exit 1
fi


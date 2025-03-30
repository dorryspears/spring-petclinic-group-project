#!/bin/bash

# Create reports directory
mkdir -p /zap/reports

# Run ZAP scan
zap-baseline.py -t $TARGET_URL -r /zap/reports/zap-report.html -I

# Ensure reports have correct permissions
chown -R 1000:1000 /zap/reports
chmod -R 755 /zap/reports

# Copy report to mounted volume if it exists
if [ -d "/zap/wrk" ]; then
    cp /zap/reports/zap-report.html /zap/wrk/
    chown 1000:1000 /zap/wrk/zap-report.html
    chmod 644 /zap/wrk/zap-report.html
fi 
#!/bin/bash

echo "Running Unit Tests..."
echo "Running models tests..."
echo "Running Unit Tests..." >> testing_results.log
echo "Running models tests..." >> testing_results.log
flutter test test/models/ >> testing_results.log
echo "Running services tests..."
echo "Running services tests..." >> testing_results.log
flutter test test/services/ >> testing_results.log
echo "Unit Test Results saved to testing_results.log"
echo "Unit Test Results saved to testing_results.log" >> testing_results.log

echo "Running Widget Test..."
echo "Running Widget Test..." >> testing_results.log
flutter test test/widget_tests/ >> testing_results.log
echo "Widget Test Results saved to testing_results.log"
echo "Widget Test Results saved to testing_results.log" >> testing_results.log

echo "Running Integration Tests..."
echo "Running Integration Tests..." >> testing_results.log
flutter test integration_test/ >> testing_results.log
echo "Integration Test Results saved to testing_results.log"
echo "Integration Test Results saved to testing_results.log" >> testing_results.log

echo "All Tests Completed!"
echo "All Tests Completed!" >> testing_results.log

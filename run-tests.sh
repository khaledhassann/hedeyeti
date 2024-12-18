#!/bin/bash

echo "Running Unit Tests..."
echo "Running models tests..."
flutter test test/models/ > unit_test_results.log
echo "Running services tests..."
flutter test test/services/ > unit_test_results.log
echo "Unit Test Results saved to unit_test_results.log"
echo "All Tests Completed!"
#!/bin/bash

echo "Running Unit Tests..."
flutter test test/models/ > unit_test_results.log
echo "Unit Test Results saved to unit_test_results.log"

echo "All Tests Completed!"
#!/usr/bin/env bash
# Copyright (c) 2016, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

directories="reflutter reflutter_generator reflutter_test"

parent_directory=$PWD

for directory in $directories; do
  echo
  echo "*** Formatting $directory..."
  echo
  cd "$parent_directory/$directory"

  dartfmt -w $(find bin lib test -name \*.dart 2>/dev/null)
done

for directory in $directories; do
  echo
  echo "*** Building $directory..."
  echo
  cd "$parent_directory/$directory"

  pub get
  pub upgrade
  grep -q build_runner pubspec.yaml && \
      pub run build_runner build \
          --delete-conflicting-outputs \
          --fail-on-severe
done

for directory in $directories; do
  echo
  echo "*** Analyzing $directory..."
  echo
  cd "$parent_directory/$directory"

  dartanalyzer --strong --fatal-warnings --fatal-infos \
      $(find bin lib test -name \*.dart 2>/dev/null)
done

for directory in $directories; do
  echo
  echo "*** Testing $directory..."
  echo
  cd "$parent_directory/$directory"

  pub run test
done
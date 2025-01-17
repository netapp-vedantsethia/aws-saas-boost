#!/usr/bin/env bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "Starting SaaS Boost installation..."

CURRENT_DIR=$(pwd)

# Check for installer dir
if [ ! -d "${CURRENT_DIR}/installer" ]; then
	echo "Directory ${CURRENT_DIR}/installer not found."
	exit 2
fi

# Check for client/web dir
if [ ! -d "${CURRENT_DIR}/client/web" ]; then
	echo "Directory ${CURRENT_DIR}/client/web not found."
	exit 2
fi

# check for Java
if ! command -v java >/dev/null 2>&1; then
	echo "Java version 11 or higher must be installed."
	exit 2
fi

# check for Maven
if ! command -v mvn >/dev/null 2>&1; then
	echo "Maven version 3 or higher must be installed."
	exit 2
fi

# check for Yarn
if ! command -v yarn >/dev/null 2>&1; then
	echo "Yarn package manager for Node must be installed."
	exit 2
fi

# check for Node
if ! command -v node >/dev/null 2>&1; then
	echo "Node must be installed."
	exit 2
fi

# check for AWS region
if [ -z $AWS_DEFAULT_REGION ]; then
	export AWS_REGION=$(aws configure list | grep region | awk '{print $2}')
	if [ -z $AWS_REGION ]; then
		echo "AWS_REGION environment variable not set, check your AWS profile or set AWS_DEFAULT_REGION."
		exit 2
	fi
else
	export AWS_REGION=$AWS_DEFAULT_REGION
fi

cd ${CURRENT_DIR}/installer
echo "Building installer..."
mvn --quiet -Dspotbugs.skip > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Error building installer for SaaS Boost."
	exit 2
fi

cd ${CURRENT_DIR}/client/web
echo "Downloading Node dependencies for React web app..."
yarn
if [ $? -ne 0 ]; then
	echo "Error executing Yarn, check Node version per documentation."
	exit 2
fi

cd ${CURRENT_DIR}
clear
echo "Launching installer for SaaS Boost..."

java -Djava.util.logging.config.file=logging.properties -jar ${CURRENT_DIR}/installer/target/SaaSBoostInstall-1.0.0-shaded.jar

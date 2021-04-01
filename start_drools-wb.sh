#!/usr/bin/env bash

# Start Wildfly with the given arguments.
echo "Running Drools Workbench on JBoss Wildfly..."
exec ./standalone.sh -b $JBOSS_BIND_ADDRESS -c $KIE_SERVER_PROFILE.xml -Dorg.uberfire.nio.git.dir=/home/youruser/some/path -org.uberfire.nio.git.ssh.host=0.0.0.0
exit $?
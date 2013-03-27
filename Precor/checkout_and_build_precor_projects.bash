#!/bin/sh

# NOTE: you'll need to upload a valid Maven settings.xml file to ~/.m2/settings.xml

echo "export MAVEN_OPTS='-Xmx1024m -XX:MaxPermSize=256m'" >> ~/.bash_profile
source ~/.bash_profile

# checkout chronos and run
svn checkout svn://precorbeaker/platform/chronos/trunk /stor/project_roots/chronos/ --username gary.affonso
pushd /stor/project_roots/chronos
mvn clean install
popd

# checkout apollo (exerciser-api)
svn checkout svn://precorbeaker/platform/preva/exerciser-api/trunk/ /stor/project_roots/apollo/ --username gary.affonso
pushd /stor/project_roots/apollo
mvn clean install
popd

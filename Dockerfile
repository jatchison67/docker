FROM jboss/base-jdk:11

####### MAINTAINER ############
MAINTAINER "John Atchison" "jatchison@solutionstream.com"

####### ENVIRONMENT ############
ENV JAVA_OPTS -Xms256m -Xmx2048m -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8
ENV WILDFLY_VERSION 20.0.1.Final
ENV WILDFLY_SHA1 95366b4a0c8f2e6e74e3e4000a98371046c83eeb
ENV JBOSS_HOME /opt/jboss/wildfly
ENV JBOSS_BIND_ADDRESS 0.0.0.0
ENV KIE_REPOSITORY https://repository.jboss.org/nexus/content/groups/public-jboss
ENV KIE_VERSION 7.42.0.Final
ENV KIE_CLASSIFIER wildfly19
ENV KIE_CONTEXT_PATH business-central
ENV KIE_SERVER_PROFILE standalone-full

####### CONFIGURATION ############
USER root

####### WILDFLY ############
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

####### DROOLS-WB ############
RUN curl -o $HOME/$KIE_CONTEXT_PATH.war $KIE_REPOSITORY/org/kie/business-central/$KIE_VERSION/business-central-$KIE_VERSION-$KIE_CLASSIFIER.war && \
unzip -q $HOME/$KIE_CONTEXT_PATH.war -d $JBOSS_HOME/standalone/deployments/$KIE_CONTEXT_PATH.war &&  \
touch $JBOSS_HOME/standalone/deployments/$KIE_CONTEXT_PATH.war.dodeploy &&  \
rm -rf $HOME/$KIE_CONTEXT_PATH.war

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

# COPY standalone.sh /opt/jboss/wildfly/bin/
# COPY standalone.conf /opt/jboss/wildfly/bin/
ADD start_drools-wb.sh $JBOSS_HOME/bin/start_drools-wb.sh
RUN chown jboss:jboss $JBOSS_HOME/bin/start_drools-wb.sh
RUN /opt/jboss/wildfly/bin/add-user.sh -a -u kieworkbench -p workbench1! -g admin,kie-workbench
RUN /opt/jboss/wildfly/bin/add-user.sh -a -u kieadmin -p admin1! -g admin,kie-server

####### CUSTOM JBOSS USER ############
USER jboss
WORKDIR $JBOSS_HOME
####### EXPOSE INTERNAL JBPM GIT PORT ############
EXPOSE 8080 8001

####### RUNNING DROOLS-WB ############
## CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0", "-c", "standalone-full.xml"]
CMD ["./start_drools-wb.sh"]
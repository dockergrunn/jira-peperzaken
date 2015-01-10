#
# An extended image with the java controller added to the <JIRA installation directory>/lib/.
# Basics
#
FROM durdn/atlassian-base
MAINTAINER Jasper Swaagman <j.swaagman@peperzaken.nl>

# Install Jira
ENV JIRA_VERSION 6.3.7
RUN curl -Lks http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}.tar.gz -o /root/jira.tar.gz \
  && /usr/sbin/useradd --create-home --home-dir /opt/jira --groups atlassian --shell /bin/bash jira \
  && tar zxf /root/jira.tar.gz --strip=1 -C /opt/jira
  && chown -R jira:jira /opt/atlassian-home \
  && echo "jira.home = /opt/atlassian-home" > /opt/jira/atlassian-jira/WEB-INF/classes/jira-application.properties \
  && chown -R jira:jira /opt/jira \
  && mv /opt/jira/conf/server.xml /opt/jira/conf/server-backup.xml 

ENV CONTEXT_PATH ROOT
COPY launch.bash /launch
RUN chmod u+x /launch

# Get the java controller.
ENV CONNECTOR mysql-connector-java-5.1.32
WORKDIR /opt/jira
USER root 
RUN wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.32.tar.gz \
  && tar zxf ${CONNECTOR}.tar.gz ${CONNECTOR}/${CONNECTOR}-bin.jar \
  && mv ${CONNECTOR}/${CONNECTOR}-bin.jar lib/

# Launching Jira
VOLUME ["/opt/atlassian-home"]
EXPOSE 8080
CMD ["/launch"]

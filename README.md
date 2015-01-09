# jira-peperzaken
Our JIRA setup

@TODO: 
* Our setup, with nginx proxy and ssl.

This setup consists of multiple containers.

  1. Jira (Java process)
  2. MySQL 
  3. Data-container

We begin by starting our data-container:
```bash
  docker run --name jira_data -v /opt/atlassian-home busyboxy true
```

Next we start up our MySQL container
```bash
  docker run -dit \
  -e MYSQL_ROOT_PASSWORD="secretpass" \
  -e MYSQL_USER="jira_db_user" \
  -e MYSQL_PASSWORD="moresecretpass" \
  -e MYSQL_DATABASE="jira_db" \
  --name mysql \ 
  mysql:5 
```

Finally we start our Jira.
```bash
  docker run -dit --name jira --volumes-from jira_data --link mysql:mysql jira-peperzaken
```

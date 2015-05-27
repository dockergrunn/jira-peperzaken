# Jira at Peperzaken

The setup we use to host our Jira instance at Peperzaken.
The setup consists of 3 containers:
* Jira
* MySQL
* Nginx

**Table of content**

1. [TODO](#todo)
2. [Quick Start](#quick-start)
 * [Docker-compose](#docker-compose-fig)
 * [docker-compose.yml](#docker-compose-yml)
 * [HTTS](#https)



## TODO
* Add the https connector to the image
* Jira needs a decent machine to run properly. It can happen that the configuration part gives you a timeout on the database connection. To solve this, the timeout time on the nginx proxy needs to be increased.

## Quick Start

### Docker-compose (Fig)
The containers can be started by using the `docker-compose.yml` file.
To get docker-compose:
```bash
sudo wget https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname  -s`-`uname -m` -O /usr/local/bin/docker-compose
```

To run everything:
```bash
docker-compose up -d
````

### docker-compose.yml
```yaml
mysql: # You can also use the internal HSQL database, this mysql block can be removed then
    image: mysql
    environment:
        MYSQL_ROOT_PASSWORD: "secretpass"
        MYSQL_DATABASE: "jiradb"
        MYSQL_USER: "jiradbuser"
        MYSQL_PASSWORD: "manysecretpass"
    volumes:
        - /where/you/want/your/mysql/data:/var/lib/mysql # For persistent mysql data; you can also use a data-container.
jira:
    build: . # The Dockerfile builds forth on an Ubuntu/Java image (see Dockerfile)
    environment:
        VIRTUAL_HOST: "jira.mycompany.com" # Where you want your jira to be accessed (env for the nginx container)
    links:
        - mysql
    volumes:
        - /where/you/want/your/jira/data:/opt/atlassian-home # For persistent jira data; you can also use a data-container.
nginx:
    image: jwilder/nginx-proxy # See https://github.com/jwilder/nginx-proxy
    volumes:
        - /where/you/want/your/nginx/configs/:/etc/nginx/conf.d # The place where you can place custom nginx config lines.
        - /where/you/want/your/tls/certs:/etc/nginx/certs # The place where you place your cert + key
        - /var/run/docker.sock:/tmp/docker.sock
    ports:
        - "80:80" # I don't think this is needed :)
        - "443:443"
```

### HTTPS
If you want to use HTTPS (which you should if you are publishing it to the internet) you have to add a line to `conf/server-backup.xml`.
You can do this after you have configured Jira. Make sure to change the `proxyName` at the end of the line.
```bash
sed -i '48i <Connector acceptCount="100" connectionTimeout="20000" disableUploadTimeout="true" enableLookups="false" maxHttpHeaderSize="8192" maxThreads="150" minSpareThreads="25" port="8080" protocol="HTTP/1.1" redirectPort="8443" useBodyEncodingForURI="true" scheme="https" proxyName="jira.mycompany.com" proxyPort="443" secure="true"/>' conf/server-backup.xml
```

**Oneliner**

didn't test it \^.^
```bash
containerid=$(docker ps | grep /launch | awk -F" " '{print $1}'); \
docker exec $containerid \
sed -i '48i <Connector acceptCount="100" connectionTimeout="20000" disableUploadTimeout="true" enableLookups="false" maxHttpHeaderSize="8192" maxThreads="150" minSpareThreads="25" port="8080" protocol="HTTP/1.1" redirectPort="8443" useBodyEncodingForURI="true" scheme="https" proxyName="jira.mycompany.com" proxyPort="443" secure="true"/>' conf/server-backup.xml
```
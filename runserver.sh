#!/bin/sh

MYSQL_CONNECTOR_PACKAGE="mysql-connector-java-5.1.38.tar.gz"
MYSQL_CONNECTOR_DOWNLOAD="http://dev.mysql.com/get/Downloads/Connector-J"
BASH_FILE="/opt/TeamCity/bin/teamcity-server.sh"

if [ ! -f $TEAMCITY_DATA_PATH/lib/jdbc/mysql-connector-java-5.1.38-bin.jar ]; then
    mkdir -p $TEAMCITY_DATA_PATH/lib/jdbc

    # MySQL JDBC connector needed to use MySQL 
    wget $MYSQL_CONNECTOR_DOWNLOAD/$MYSQL_CONNECTOR_PACKAGE
    tar zxf $MYSQL_CONNECTOR_PACKAGE -C $TEAMCITY_DATA_PATH/lib/jdbc
    rm -rf $MYSQL_CONNECTOR_PACKAGE

    mv $TEAMCITY_DATA_PATH/lib/jdbc/mysql-connector-java-5.1.38/mysql-connector-java-5.1.38-bin.jar $TEAMCITY_DATA_PATH/lib/jdbc/mysql-connector-java-5.1.38-bin.jar
fi

if [ ! -f $TEAMCITY_DATA_PATH/plugins/agentAutoAuthorize.jar ]; then
    mkdir -p $TEAMCITY_DATA_PATH/plugins

    # Plugin needed for self authentication of the agents
    wget https://github.com/matt-richardson/TeamCityAgentAutoRegisterPlugin/releases/download/v0.1.0/agentAutoAuthorize.zip
    mv agentAutoAuthorize.zip $TEAMCITY_DATA_PATH/plugins/agentAutoAuthorize.zip
fi

if [ ! -f $TEAMCITY_DATA_PATH/config/internal.properties ]; then
    mkdir -p $TEAMCITY_DATA_PATH/config
    
    # Token every agent has to know who wants to self-authenticate
    echo "teamcity.agentAutoAuthorize.authorizationToken=70d44d1e5007dd6b" >> $TEAMCITY_DATA_PATH/config/internal.properties

    # Make sure no "First step" stuff is shown to the user 
    # -> we do configure the database server in this script
    echo "teamcity.startup.maintenance=false" >> $TEAMCITY_DATA_PATH/config/internal.properties

    # Database server configuration
    echo "connectionProperties.user="$DB_USER >> $TEAMCITY_DATA_PATH/config/database.properties
    echo "connectionProperties.password="$DB_PASS >> $TEAMCITY_DATA_PATH/config/database.properties
    echo "connectionUrl=jdbc\:mysql\://mysql\:3306/"$DB_NAME >> $TEAMCITY_DATA_PATH/config/database.properties
fi

# Make sure the teamcity-server.sh file is executable
chmod +x $BASH_FILE

# Run the TeamCity server
sh $BASH_FILE run


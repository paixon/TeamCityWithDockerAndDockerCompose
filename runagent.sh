#!/bin/sh

AGENT_FOLDER="/home/teamcity/agent/"
PROPERTIES_FILE=$AGENT_FOLDER"conf/buildAgent.properties"
BASH_FILE=$AGENT_FOLDER"/bin/agent.sh"

mkdir -p $AGENT_FOLDER
   
if [ ! -f $BASH_FILE ]; then
    while [ 1 ]; do
	# Try to get the buildAgent.zip from our TeamCity Server
	# Usually the server needs some time to boot, this is why we have to
	# retry here a view times
        wget http://server:8111/update/buildAgent.zip
        if [ $? = 0 ]; 
	    then break; 
	fi; 

        sleep 5s;
    done;

    unzip buildAgent.zip -d $AGENT_FOLDER
    rm -rf buildAgent.zip

    # Tell the agent where his TeamCity server can be found
    echo "serverUrl=http://server:8111" >> $PROPERTIES_FILE

    # Povide the authentication Token we have configured on the server
    echo "teamcity.agentAutoAuthorize.authorizationToken=70d44d1e5007dd6b" >> $PROPERTIES_FILE
fi

chmod +x $BASH_FILE

sh $BASH_FILE run

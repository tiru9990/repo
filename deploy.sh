#*****************************
#Deployment Automation script
#File Name: deploy.sh
#Author: XXXX
#Date  : 12/09/2017
#Desc: This script used to deploy the App an DB artifacts on given env
#USAGE: sh deploy.sh deploy


echo "******** DEPLOYMENT AUTOMATION OF LEA+D APP ******"
TOMCAT_HOME="/home/vagrant/apache-tomcat-7.0.70/"
USER="vagrant"
function stopTomcat()
{
  echo "-- Stopping Tomcat instance"
  ssh $USER@192.168.20.11  "sh $TOMCAT_HOME/bin/shutdown.sh"
  sleep 3
  [ $? -eq 0 ] && echo "Tomcat has been stopped successfully"
}

function startTomcat()
{
  echo "-- Starting Tomcat instance"
  ssh $USER@192.168.20.11  "sh $TOMCAT_HOME/bin/startup.sh"
  sleep 2 
  [ $? -eq 0 ] && echo "Tomcat has been started successfully"

}

function backupApp()
{
  echo "-- Backup the war file"
  ssh $USER@192.168.20.11  "mv $TOMCAT_HOME/webapps/leadapp.war /home/vagrant/backup/leadapp.war_`date '+%Y-%m-%d_%H-%M-%S'`"
}

function backupDB()
{
  echo "-- Backup the db "
  ssh $USER@192.168.20.11 "mysqldump -u harry -pharry leadapp > /home/vagrant/db_dump.sql_`date '+%Y-%m-%d_%H-%M-%S'`"
  [ $? -eq 0 ] && echo "DB Backup  has been started successfully"
}

function deployDB()
{
  echo "-- DB DEployment started"
  scp src/database/schema.sql $USER@192.168.20.11:
  ssh $USER@192.168.20.11  "mysql -u harry -pharry leadapp < /home/vagrant/schema.sql" 
 [ $? -eq 0 ] && echo "DB deployment completed succesfully"
}

function deployApp()
{
  echo "-- App deployment starte"
  scp dist/lib/leadapp.war $USER@192.168.20.11:$TOMCAT_HOME/webapps/
 [ $? -eq 0 ] && echo "App deployment completed succesfully"
}


echo  Started at `date`
if [ $# -eq 1 ]
then
	case $1 in
	deploy) stopTomcat 
		backupApp 
                backupDB
		deployDB
		deployApp
		startTomcat ;;
	restart) stopTomcat
 		 startTomcat ;;
	*) 	echo Wrong deploy task ;;
	esac
else
	echo "USAGE: sh deploy.sh deploy/restart"

fi
echo complete at `date`

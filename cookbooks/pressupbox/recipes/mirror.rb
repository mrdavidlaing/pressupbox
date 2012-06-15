file "/tmp/pressupbox_mirror.lock" do
  owner "root"
  group "root"
  mode "0777"
  action :create
end

ruby_block "aquire run lock" do
  block do
    lockfile = File.new('/tmp/pressupbox_mirror.lock')
	lockfile.flock(File::LOCK_EX | File::LOCK_NB) or fail "Another recipe[pressupbox::mirror] run is currently in progress.  Only a single mirror run can be performed at any one time."
  end
  action :create
end

bash "mirror_to_aws" do
  timeout 5400  #let the job run for a max of 90 min
  
  user "root"
  cwd "/root"
  code <<-EOH
# Amazon login parameters
export EC2_PRIVATE_KEY=`ls ~/.ec2/pk-*.pem`
export EC2_CERT=`ls ~/.ec2/cert-*.pem`

# EC2 tools path
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/jre

### Machine image you want to use as the base for the machine you want to start up, more on this later.
export amiid=`cat ~/.ec2/www1-backup.ami`

### SSH key to use to setup the machine with. In the EC2 console you need to setup an 
#SSH key that you can connect to your new machine with as by default they do not allow access 
# by any other means. This is my own keyname on the console.
export key="web-angle-EU-West1"

### Local SSH key to connect to machine with. Location of the actual SSH 
#key that you also put in the EC2 console.
export id_file="/root/.ec2/web-angle-EU-West1.pem"

### Where do launch your machine
export region="eu-west-1"
export zone="eu-west-1b"

### Security group. To help me identify my machine, I use security groups as EC2 doesn't have real instance labels.
export group="WWW"

### Maximum price for amazon spot instance
export price=".05"

### The list of databases we want to backup (essentially all except the system dbs)
DBS_TO_BACKUP=`mysql -Bse "show databases;" | egrep -v 'performance_schema|information_schema'| tr '\\n' ' '`

check_errs()
{
  # Function. Parameter 1 is the return code
  # Para. 2 is text to display on failure.
  if [ "${1}" -ne "0" ]; then
    echo "ERROR # ${1} : ${2}"
    #Shutdown the instance we started
    ec2-terminate-instances --region ${region} ${iid}
    # as a bonus, make our script exit with the right error code.
    exit ${1}
  fi
}

## main script starts here ###

#
# Start the instance
# Capture the output so that
# we can grab the INSTANCE ID field
# and use it to determine when
# the instance is running
#

echo Requesting spot instance ${amiid} with price of ${price}

ec2-request-spot-instances --region ${region} ${amiid} --price ${price} -z ${zone} -k "${key}" --group ${group} > /tmp/a
check_errs $? "Error requesting spot instance for image ${amiid}"

export rid=`cat /tmp/a | grep SPOTINSTANCEREQUEST | cut -f2`

#
# While we're waiting for the spot instance to start up, make a hot copy
# of the databases
#
echo "take a snapshot of mysql dbs"

check_errs $? "unable to take snapshot of mysql dbs"

#
# Loop until the status changes to 'active'
#

sleep 30
echo Checking request ${rid}
export ACTIVE="active"
export done="false"
while [ $done == "false" ]
do
 export request=`ec2-describe-spot-instance-requests --region ${region} ${rid} | grep SPOTINSTANCEREQUEST`
 export status=`echo $request | cut -f6 -d' '`
 if [ $status == ${ACTIVE} ]; then
  export done="true"
  export iid=`echo $request | cut -f8 -d' '`
 else
  echo Waiting...
  sleep 60
 fi
done
echo Request ${rid} is active

#
# Loop until instance is running
#

echo Waiting for instance to start...
export done="false"
export RUNNING="running"
while [ $done == "false" ]
do
  export status=`ec2-describe-instances --region ${region} ${iid} | grep INSTANCE  | cut -f6`
  if [ $status == ${RUNNING} ]; then
    export done="true"
    sleep 30 #wait just a leetle bit longer, so the services have a chance to get going
  else
    echo Waiting...
    sleep 10
  fi
done
echo Instance ${iid} is running.

export EC2_HOST=`ec2-describe-instances  --region ${region} | grep "${iid}" | tr '\t' '\n' \
| grep amazonaws.com`

### Important trick here.
### 1. Because you will be starting up a different machine every time you run this script, you'll be forced to say yes to accepting the change of host for the SSH key, the options here make sure the doesn't happen and you can run this completely automated without human interaction.
### 2. Since we don't want to save the host SSH key, we will redirect the known hosts list to a temp file
export KNOWN_HOSTS='/tmp/known_hosts.$$'
rm $KNOWN_HOSTS

#Ensure the /data folder is mounted
ssh -i ${id_file} -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=$KNOWN_HOSTS" ubuntu@$EC2_HOST 'sudo echo "/dev/xvdf    /data    auto   defaults,nobootwait   0    2" | sudo tee -a /etc/fstab && sudo mount -a'

### Copy of the mysql snapshot 
echo "mirror_mysql: start"
#ssh -i ${id_file} -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=$KNOWN_HOSTS" ubuntu@$EC2_HOST "sudo service mysql stop" 
nice -n19 ionice -c3 rsync  -e "ssh -i ${id_file} -o 'UserKnownHostsFile=$KNOWN_HOSTS'" --rsync-path "sudo rsync" --quiet --exclude=debian-5.1.flag --exclude=ibdata1 --exclude=ib_logfile* --exclude=mysql_upgrade_info --delete-during --inplace -aEzh --log-file=/var/log/pressupbox/mirror_msql.log /data/mysql_snapshots/. ubuntu@$EC2_HOST:/data/mysql/.
check_errs $? "unable to rsync mysql snapshot"
#ssh -i ${id_file} -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=$KNOWN_HOSTS" ubuntu@$EC2_HOST "sudo service mysql start" 
check_errs $? "unable to start remote mysql service"
echo "mirror_mysql: done"

### Copy of the app_containers
echo "mirror_appcontainers: start"
nice -n19 ionice -c3 rsync  -e "ssh -i ${id_file} -o 'UserKnownHostsFile=$KNOWN_HOSTS'" --rsync-path "sudo rsync"  --quiet --delete-during --inplace -aEzh --log-file=/var/log/pressupbox/mirror_appcontainers.log /data/app_containers/. ubuntu@$EC2_HOST:/data/app_containers/.
check_errs $? "unable to rsync app_containers"
echo "mirror_appcontainers: done"

### Bundle instance into an AMI
export new_ami=`ec2-create-image --region ${region} ${iid} --name "www1-backup at $(date +%Y%m%dT%H%M%S)" --description "Snapshot of  ${iid} created at $(date +%Y%m%dT%H%M%S)"  | awk '{ printf $2; }'`
check_errs $? "Unable to bundle instance into AMI"

#Save for next run
echo ${new_ami} > ~/.ec2/www1-backup.ami

sleep 60
echo Terminating "backup" instance ${iid}
ec2-terminate-instances --region ${region} ${iid}
check_errs $? "Unable to terminate "backup" instance ${iid}"

echo Bundling new AMI ${new_ami}
#
# Loop until the status changes to 'active'
#
echo Waiting for AMI to be created ${new_ami}
export done="false"
while [ $done == "false" ]
do
 export request=`ec2-describe-images --region ${region} ${new_ami} | grep IMAGE`
 export status=`echo $request | cut -f7 -d' '`
 if [ $status == 'available' ]; then
  export done="true"
 else
  echo Status: $status - Waiting...
  sleep 60
 fi
done
check_errs $? "Error occured in creation of new AMI ${new_ami}"
echo AMI ${new_ami} is available

echo "mirror: done!"
  EOH
end


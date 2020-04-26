#!/bin/bash

#HADOOP_HME="/home/hadoop"

# Create a haddop user and set password
#echo "Creating hadoop user"
#echo ""

#useradd hadoop; echo -e "hadoop\nhadoop" | passwd hadoop

# Change ownership of /usr/local/hadoop

#chown -R hadoop.hadoop /usr/local/hadoop

# Disable selinux in Red Hat / CentOS
echo "Disabling selinux on server..."
echo ""

sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# Install openjdk, wget, mlocate, vim
echo "Installing openjdk, wget, mlocate, vim..."
echo ""

sudo yum install java-1.8.0-openjdk* wget mlocate vim -y

# Download apache hadoop 1.2.1 from apache.org
echo "Downloading apache hadoop..."
echo ""

#wget https://archive.apache.org/dist/hadoop/common/hadoop-1.2.1/hadoop-1.2.1.tar.gz -P /home/hadoop
sudo wget https://archive.apache.org/dist/hadoop/common/hadoop-1.2.1/hadoop-1.2.1.tar.gz

# Change directory extract and apache hadoop tarball and provide permission to hadoop directory

#cd $HADOOP_HME
#cd /home/hadoop

echo "Extracting apache hadoop.."
echo ""

# Create hadoop directroy in /usr/local

sudo mkdir -p /usr/local/hadoop

sudo tar -xvf hadoop-1.2.1.tar.gz --strip 1 -C /usr/local/hadoop
#tar -xvf hadoop-1.2.1.tar.gz -C /usr/local/hadoop

echo "Changing permission of hadoop directory"
echo ""

sudo chown -R ec2-user.ec2-user /usr/local/hadoop

# create a rsa key copy to authorized_keys and set permission of authorized_keys file

echo "Creating ssh key and copy to authorized_keys..."
echo ""

#sudo -u hadoop ssh-keygen -t rsa -N "" -f /home/hadoop/.ssh/id_rsa
#sudo -u ec2-user ssh-keygen -t rsa -N "" -f /home/ec2-user/.ssh/id_rsa
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

#sudo -u hadoop ssh-copy-id hadoop@localhost

#sudo -u hadoop cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
sudo -u ec2-user cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
sudo cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#chmod 600 /home/hadoop/.ssh/authorized_keys

# Check ssh connection 

ssh -q -o StrictHostKeyChecking=no ec2-user@localhost exit
echo $?

# Set JAVA_HOME and HADOOP_HOME (environment variables)

echo "Setting up the JAVA_HOME environment..."
echo ""

sudo cat <<EOT >> ~/.bashrc
export HADOOP_PREFIX=/usr/local/hadoop/
export PATH=\$PATH:\$HADOOP_PREFIX/bin
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
export PATH=\$PATH:\$JAVA_HOME
EOT

echo "Configuring hadoop xml's..."
echo ""

core_site="<property>\n <name>fs.default.name</name>\n <value>hdfs://localhost:9000</value>\n </property>\n\n <property>\n <name>hadoop.tmp.dir</name>\n <value>/usr/local/hadoop/tmp</value>\n </property>"

sed -i "/<configuration>/a $core_site" /usr/local/hadoop/conf/core-site.xml

hdfs_site="<property>\n <name>dfs.replication</name>\n <value>1</value>\n </property>"

sed -i "/<configuration>/a $hdfs_site" /usr/local/hadoop/conf/hdfs-site.xml

mapred_site="<property>\n <name>mapred.job.tracker</name>\n <value>hdfs://localhost:9001</value>\n </property>"

sed -i "/<configuration>/a $mapred_site" /usr/local/hadoop/conf/mapred-site.xml

echo "Setting up the HADOOP_HOME environment..."
echo ""

sudo cat <<EOT >> /usr/local/hadoop/conf/hadoop-env.sh
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
export HADOOP_OPTS=-Djava.net.preferIPV4Stack=true
EOT


# Loading bashrc

echo "Loading bashrc profile..."
echo ""

. ~/.bashrc

# Create a directory for data

#sudo -u hadoop mkdir /usr/local/hadoop/tmp
sudo -u ec2-user mkdir /usr/local/hadoop/tmp

# Format DFS file system 

echo "Formatting hdfs file system..."
echo ""

#sudo -u ec2-user hadoop namenode -format
hadoop namenode -format

echo "Starting hadoop deamons..."
echo ""

#sudo -u ec2-user /usr/local/hadoop/bin/start-all.sh
/usr/local/hadoop/bin/start-all.sh

echo "Below deamons are started"
echo ""

jps

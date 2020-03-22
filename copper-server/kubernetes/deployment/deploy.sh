
#!/bin/bash


set -e

ECHO=`which echo`
KUBECTL=`which kubectl`

# methods

# color refference
#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

# Creating The Banner
#Colours
red="\033[00;31m"
RED="\033[01;31m"

green="\033[00;32m"
GREEN="\033[01;32m"

brown="\033[00;33m"
YELLOW="\033[01;33m"

blue="\033[00;34m"
BLUE="\033[01;34m"

purple="\033[00;35m"
PURPLE="\033[01;35m"

cyan="\033[00;36m"
CYAN="\033[01;36m"

white="\033[00;37m"
WHITE="\033[01;37m"

WHITECHAR="\033[01;39m"

NC="\033[00m"
BOLD="\e[1m"
NRM="\e[0m"

echo "${RED}******************************************************************************"
echo "${WHITE}**                                                                          **"
echo "${WHITECHAR}**          POWERED BY LANKA SOFTWARE FOUNDATION  (LSF)                     **"
echo "${WHITE}**                                                                          **"
echo "${RED}******************************************************************************"

#   Add follwing tag after command for ignoring stdout, errors etc
#   > /dev/null throw away stdout
#   1> /dev/null throw away stdout
#   2> /dev/null throw away stderr
#   &> /dev/null throw away both stdout and stderr


# method to print bold
function echoBold () {
    ${ECHO} $'\e[1m'"${1}"$'\e[0m'
}

# method to print red bold fonts 
function echoRedBold () {
    #    .---------- constant part!
    #    vvvv vvvv-- the code from above
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    BD='\e[1m' # bold
    NM='\e[0m' # normal size
    RDBD='\033[0;31m\e[1m' # red and bold
    RDNM='\e[0m\033[0m' # normal color and normal size
    #printf "* ${BD}${RED}-${1} ${NC}${NM}\n"
    #${ECHO} ${RED}${1}
    printf "* ${RDBD}-${1} ${RDNM}\n"
    
}

# method to print red bold fonts 
function echoGreenBold () {
    #    .---------- constant part!
    #    vvvv vvvv-- the code from above
    RED='\033[0;32m' # green
    NC='\033[0m' # No Color
    BD='\e[1m' # bold
    NM='\e[0m' # normal size
    RDBD='\033[0;32m\e[1m' # green and bold
    RDNM='\e[0m\033[0m' # normal color and normal size
    #printf "* ${BD}${RED}-${1} ${NC}${NM}\n"
    #${ECHO} ${RED}${1}
    printf "* ${RDBD}-${1} ${RDNM}\n"
    
}

## simplifying the installer

# -------------------------------------
read -r -p "You are going to install copper Email. You should have coppied your certificate and key files to tls folder. Are you ready? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])

# checking cert file list
# - cert.pem
# - fullchain.pem
# - privkey.key
# - dhparam.pem

# checking the cert.pem files exists
file="../tls/cert.pem"
if [ ! -f "$file" ]
then
    echoRedBold "$0: cert.pem file '${file}' not found in tls directory. !"
    #exit 3 
fi

# checking the privkey.key files exists
file="../tls/privkey.pem"
if [ ! -f "$file" ]
then
    echoRedBold "$0: privkey.pem file '${file}' not found in tls directory. !"
    #exit 3 
fi

# checking the dhparam.pem files exists
file="../tls/dhparam.pem"
if [ ! -f "$file" ]
then
    echoRedBold "$0: dhparam.pem file '${file}' not found in tls directory. !"
    #exit 3 
fi

# checking the fullchain.pem files exists
#file="../tls/fullchain.pem"
#if [ ! -f "$file" ]
#then
#    echoRedBold "$0: fullchain.pem file '${file}' not found in tls directory. !"
#    exit 3 
#fi

echoGreenBold 'Certificate files are avaialbe in the tls folder'
#-----------

echoGreenBold 'What is your business''s domain name?'
echo 'Enter your business''s domain name ( E.g. example.com ):'
read domain_name

## we need to split domain by . and assign to DC1, DC2 and DC3 (assuming 3 levels is the max)
IFS='.' # space is set as delimiter
read -ra ADDR <<< "$domain_name"
x=1;
for i in "${ADDR[@]}"; do
    if [ $x -eq 4 ] 
	then
	   echo "We only support 3 levels depth in the domain name"
	   exit 0;
    fi
    if [ $x -eq 1 ]
	then 
	   DC1="$i"
    fi
    if [ $x -eq 2 ]
        then
           DC2="$i"
    fi
    if [ $x -eq 3 ]
        then
           DC3="$i"
    fi
    let x=x+1
done

echoGreenBold 'Setting up admin account'
echo "Enter username for admin account ( E.g. enter admin for admin@$domain_name ):"
read admin_username
echo 'Enter password for admin account:'
read admin_password

# mysql config
mysql_db="copper"
mysql_user="root"
#mysql_db_pwd=`openssl rand -base64 12`
mysql_db_pwd=c0pperDB

#ldap config

ro="admin"
ro_pass=`openssl rand -base64 12`
rspamd_pwd=`openssl rand -base64 12`

echoGreenBold 'Deploying Copper Email Server...'

############## START OF CONFIGURATION #############################

# move to template based configuration
# need to test string limit. This might be exceed the string limit

s0="s/<<DOMAIN>>/$domain_name/g;"
s1="s/<<CN-ADMIN>>/$admin_username/g;"
s2="s/<<CN-ADMIN>>/$admin_username/g;"
s3="s/<<CN-ADMIN-PASSWD>>/$admin_password/g;" 
s4="s/<<DATABASE>>/$mysql_db/g;"
s5="s/<<MYSQL-USER>>/$mysql_user/g;"
s6="s/<<MYSQL-PASSWD>>/$mysql_db_pwd/g;"
s7="s/<<RO>>/$ro/g;"
s8="s/<<RO-PASSWD>>/$ro_pass/g;"
s9="s/<<RSPAMD-PASSWD>>/$rspamd_pwd/g;"
d1="s/<<DC1>>/$DC1/g;"
d2="s/<<DC2>>/$DC2/g;"
d3="s/<<DC3>>/$DC3/g;"

# Now Create the configuration secrets
s="$s0 $s1 $s2 $s3 $s4 $s5"
sed "$s" templates/secret.yaml.tmpl > secret.yaml
cat secret.yaml > secret.yaml.tmp

# split sed to 2 commands to avoid exceed string limit
s="$s6 $s7 $s8 $s9 $d1 $d2 $d3"
sed "$s" secret.yaml.tmp > secret.yaml
cat secret.yaml > secret.yaml.tmp

# remove DC3 line if DC3 is empty
if [ -z $DC3 ] 
    then
    sed '/^    DC3:/d' secret.yaml.tmp > secret.yaml
fi

echoGreenBold 'Configuration going to be create...'

################ Creating LDAP yaml for LDAP configuration

if [ -z $DC3 ] 
    then
        dc="dc=$DC1,dc=$DC2"
    else
        dc="dc=$DC1,dc=$DC2,dc=$DC3"
fi

sed "s/<<DC>>/$dc/g; s/<<DOMAIN>>/$domain_name/g;" templates/ldap.ldif.tmpl > ldap.ldif

echoGreenBold 'ldap.ldif file was Created...'

exit
######### END OF CONFIGURATION #############################################
# starting kubernetes deployment
# Creating the k8s namespace
kubectl create namespace copper >> installer.log
echoGreenBold 'Copper namespace created...'

kubectl create -f secret.yaml >> installer.log
echoGreenBold 'Copper secret created...'

# changing to parent directory
cd ..

# Creating ldap server
kubectl create -f openldap/openldap.yaml >> installer.log
echoGreenBold 'openldap service created...'
# Create the phpldapadmin service  
kubectl create -f phpldapadmin/phpldapadmin.yaml >> installer.log
echoGreenBold 'phpldapadmin service Created...'
# creating emailserver docker image
#cd emailserver
#docker build -t emailserver . 2> /dev/null || true
#echoGreenBold 'Docker Email image Service Created...'
# wait 1 seconds 
#sleep 3s
#cd ..

# Create the emailserver service from kubernetes using docker image we have created now.
kubectl create -f emailserver/email.yaml >> installer.log
echoGreenBold 'email service created...'
#Building docker image

# Create the persistent volume and persistent volume claim for database
#kubectl create -f persistent/mysql-pv.yaml  >> installer.log
#echoGreenBold 'Persistent Volume created...'
# Create mysql deployment
#kubectl create -f persistent/mysql-deployment.yaml >> installer.log
#echoGreenBold 'mysql deployment completed...'


# >>>>>> Start of prometheus stack deployment (bellow all commands should be activated)

#Prometheus implementation
# Creating a roll has the access for clusters and bind the cluster roll.
##kubectl create -f prometheus-alert/clusterRole.yaml 2> /dev/null || true
#echoGreenBold 'Role creation and Role binding...'

# Create the config map to keep configuration data of prometheus
##kubectl create -f prometheus-alert/config-map.yaml -n copper 2> /dev/null || true
#echoGreenBold 'Prometheus configuration created...'

# Deploy prometheus pods 
##kubectl create  -f prometheus-alert/prometheus-deployment.yaml --namespace=copper 2> /dev/null || true

# Create the service to access prometheus 
##kubectl create -f prometheus-alert/prometheus-service.yaml --namespace=copper 2> /dev/null || true
#echoGreenBold 'Prometheus service created...'
# Alert manager implementation
# Creating the configuration 
##kubectl create -f prometheus-alert/AlertManagerConfigmap.yaml 2> /dev/null || true
#
##kubectl create -f prometheus-alert/AlertTemplateConfigMap.yaml 2> /dev/null || true
#echoGreenBold 'Alert Manager congiguration created..'
#
##kubectl create -f prometheus-alert/Deployment.yaml 2> /dev/null || true
#
##kubectl create -f prometheus-alert/Service.yaml 2> /dev/null || true
#echoGreenBold 'Alert Manager created...'

# >>>>>> end of prometheus stack deployment

#kubectl create -f groupware/groupoffice/groupoffice.yaml >> installer.log
#echoGreenBold 'Groupoffice created...'

# wait 1 seconds 
#sleep 1s

# Creating the namespace

#cd Apps/ldap-pw/
#docker build -t ldap-pw .
#cd ..
#cd ..

#echoGreenBold 'ldap-pw image created...'

# Creating the web server
kubectl create -f Apps/ldap-pw/ldap-pw.yaml >> installer.log
echoGreenBold 'ldap-pw created...'

# >>>>>>>>>>>> Ingress installation start  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#echoGreenBold 'Ingress creation started ....'
# install the backend
#kubectl create -f Ingress/default-backend.yaml
#echoGreenBold 'Default Back End created ....'


# creating rules for ingress
#kubectl create -f Ingress/ingress.yaml
#echoGreenBold 'ingress rules created ......'

# install the ingress controller
#kubectl create -f Ingress/nginx-controller.yaml
#echoGreenBold 'nginx-controller created ....'




#use for service starting in all email pods
# https://stackoverflow.com/questions/51026174/running-a-command-on-all-kubernetes-pods-of-a-service

echoGreenBold ' ########################################## Installation completed #######################################'
echo ""
echoGreenBold ' Please import ldap.ldif file to import a test users for testing perposes from https://localhost:4433/ url.'
echo ""
echoGreenBold ' Contact copper@opensource.lk for further assistance. ############################################'
#sleep 5s

#kubectl run -it --rm --image=mysql:5.6 --restart=Never mysql-client -n copper -- mysql -h mysql -pc0pperDB


     ;;
    *)
        echoRedBold "Deployment cancelled"
        ;;
esac

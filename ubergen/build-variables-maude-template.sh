#
# build-variables.sh
#
#	UberGen System Confabulation Suite
#   Build Variables Definition Module
#
#	Description:
#
#       Build parameters for Michigan Audit Forensics Server
#
#		The following fields need to be replaced...
#
#			Replacement Variable		Replace With
#			-------------------------	----------------------------
#			{{hostname}}				System host name
#			{{domainname}}				System domain name
#			{{root_password}}}			Root password
#			{{org_country}}				Organization country
#			{{org_state}}				Organization state
#			{{org_name}}				Organization name
#			{{org_abbr}}				Organization abbr
#			{{org_locality}}			Organization city
#			{{org_organization}}		Organization sub-organization
#			{{org_unit}}				Organization unit
#			{{org_email}}				Organization email
#			{{client_hostname}}			Cleint workstation hostname
#			{{client_ip_addr}}			Cleint workstation IPv4 address
#			{{client_email}}			Cleint workstation system admin email
#			{{ftps_command_port}}		Secure FTP command port
#			{{ftps_data_port}}			Secure FTP data port
#			{{ssh_port}}				Secure Shell (SSH) port
#			{{mariadb_port}}			MariaDB Database port
#
#	Copyright:
#		Copyright (c) 2021, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2021.12.06  01.04    KurtSchulte    MAUDe Server
#       2021.01.28  01.03    KurtSchulte    Original Version
#
####################################################################################################

scriptFolder=$(echo "${0%/*}" | sed -e "s~^[.]~`pwd`~")

# Processing Flags
#
ug_verbose=1
ug_apache_log_level='debug'

#
# Server Info
#
ug_server_name="{{hostname}}"
ug_server_domain="{{domainname}}"
ug_server_desc="Michigan Audit Forensics Server"

ug_org_name="{{org_name}}"
ug_org_country="{{org_country}}"
ug_org_state="{{org_state}}"
ug_org_locality="{{org_locality}}"
ug_org_organization="{{org_organization}}"
ug_org_unit="{{org_organization}}"
ug_org_email="{{org_email}}"
ug_org_abbr="{{org_abbr}}"

ug_server_database="{{org_abbr}}"
ug_server_webcore="{{org_abbr}}"

#
# Ports
#
ug_ftps_port={{ftps_command_port}}                      # Secure FTP command port
ug_ftps_data_port={{ftps_data_port}}                    # Secure FTP data port
ug_ssh_port={{ssh_port}}                                # Secure Shell (SSH) port
ug_db_port={{mariadb_port}}                             # MariaDB Database port
ug_ocsp_port={{ocsp_port}}                              # OCSP port

#
# SSL
# 
ug_certs_owner=root                                     # PKI Certs security owner
ug_certs_group=ssl-cert                                 # PKI Certs security group
ug_certs_servers=crl,ocsp,ica,ca                        # PKI stack server list
																		
ug_cert_encrypt_curve="secp384r1"                       # Encryption curve to use
ug_cert_life_ca=3650                                    # Certificate CA life span
ug_cert_life_server=364                                 # Server certificate life span. 1 year is max per casecurity.org

ug_cert_root_pass_phrase='<generate>'                   # Root Certificate pass phrase (generate a random one)
ug_cert_int_pass_phrase='Sn00pY4#4nD!th3!R3d#B4r0n!'  	# Intermediate CA Cert pass phrase
ug_cert_ocsp_pass_phrase=""                             # OCSP Cert pass phrase (blank for none)

#
# SSL Servers <node>;<type>;<shortdesc>;<desc>;<owner>;<group>;<prot>;<ipaddr>
#
ug_server_ca_data="ca;root;Root CA;Root Certificate Authority;${ug_certs_owner};${ug_certs_group};755;127.0.0.1"
ug_server_ica_data="ica;sign;Intermediate CA;Intermediate Certificate Authority;${ug_certs_owner};${ug_certs_group};755;127.0.0.1"
ug_server_ocsp_data="ocsp;sign;OCSP Server;On-line Certificate Status Server;${ug_certs_owner};${ug_certs_group};755;127.0.0.1"
ug_server_crl_data="crl;crl;CRL Server;Certificate Revokation List Server;${ug_certs_owner};${ug_certs_group};755;127.0.0.1"

#
# Folders
#
ug_shared_files_root=/usr/share/cognogistics            # Cognogistics shared user files					TODO: NOT USED ANYWHERE?

ug_skeleton_folder=/etc/skel                            # System folder for new user template files
ug_kits_root=/var/kits                                  # Software kits
ug_web_root=/var/www                                    # Web Data root folder
ug_ssl_root=/etc/ssl                                    # SSL Configuration root folder
ug_certs_root=/opt/ca                                   # Certificates Data Root Folder

#
# Groups
#
ug_sysgrp_system="maudsys"                              # System level users
ug_sysgrp_admin="maudadmins"                            # Administrators and super users
ug_sysgrp_dev="mauddev"                                 # Developers
ug_sysgrp_web="www-data"                                # Web Applications

#
# RHEL SELinux Security Context
#
ug_rhel_context_web="httpd_sys_content_t"               # Security context for web content

#
# Users
#	System User Data Format:
#		ug_sysuser_<userid>_data = "<username>:<userdesc>:<usergroups>:<userpass>"
#		<usergroups> is a comma separated list
#
ug_sysuser_list=sysroot,sysadmin,sysdev1,sysapp

ug_sysuser_sysroot_name=mauderoot
ug_sysuser_sysroot_desc="Michigan Audit Forensics Server Root"
ug_sysuser_sysroot_groups=${ug_sysgrp_system}:${ug_sysgrp_admin}:${ug_sysgrp_dev}:${ug_sysgrp_web}:SYSTEM:SUDO
ug_sysuser_sysroot_pass="{{root_password}}"
ug_sysuser_sysroot_data="${ug_sysuser_sysroot_name};${ug_sysuser_sysroot_desc};${ug_sysuser_sysroot_groups};${ug_sysuser_sysroot_pass}"

ug_sysuser_sysadmin_name=maudeadmin
ug_sysuser_sysadmin_desc="Michigan Audit Forensics Server Administrator"
ug_sysuser_sysadmin_groups=${ug_sysgrp_admin}:${ug_sysgrp_web}
ug_sysuser_sysadmin_pass="m4p4dm1n"
ug_sysuser_sysadmin_data="${ug_sysuser_sysadmin_name};${ug_sysuser_sysadmin_desc};${ug_sysuser_sysadmin_groups};${ug_sysuser_sysadmin_pass}"

ug_sysuser_sysdev1_name=maudedev1
ug_sysuser_sysdev1_desc="Michigan Audit Forensics Server Development"
ug_sysuser_sysdev1_groups=${ug_sysgrp_dev}:${ug_sysgrp_web}
ug_sysuser_sysdev1_pass="map#dev1"
ug_sysuser_sysdev1_data="${ug_sysuser_sysdev1_name};${ug_sysuser_sysdev1_desc};${ug_sysuser_sysdev1_groups};${ug_sysuser_sysdev1_pass}"

ug_sysuser_sysapp_name=maudeapp
ug_sysuser_sysapp_desc="Michigan Audit Forensics Server Application"
ug_sysuser_sysapp_groups=${ug_sysgrp_web}
ug_sysuser_sysapp_pass="m4p%4ppz"
ug_sysuser_sysapp_data="${ug_sysuser_sysapp_name};${ug_sysuser_sysapp_desc};${ug_sysuser_sysapp_groups};${ug_sysuser_sysapp_pass}"

#
# Stack Info
#
ug_stack_regions="prod,mod,dev"                         # Production, Model, and Development regions

# Server data
#	Server data format:
#		ug_server_<env>_data = <hostname>;<type>;<short_desc>;<desc>;<owner_user>;<owner_group>;<prot_mask>;<ip_addr>;<database>;<webcore>
#
ug_server_prod_data="${ug_server_name};app;Production;Production Server;${ug_sysuser_sysroot_name};${ug_sysgrp_web};755;127.0.0.1;${ug_server_database};${ug_server_webcore}"
ug_server_mod_data="mod.${ug_server_name};app;Model;Model Server;${ug_sysuser_sysroot_name};${ug_sysgrp_web};755;127.0.0.1;${ug_server_database}mod;${ug_server_webcore}mod"
ug_server_dev_data="dev.${ug_server_name};app;Development;Development Server;${ug_sysuser_sysroot_name};${ug_sysgrp_web};755;127.0.0.1;${ug_server_database}dev;${ug_server_webcore}dev"

#
# Client Info
#
ug_client_list="workstation1"									# Clients to generate certs for

# Client data
#	Client data format:
#		ug_server_<env>_data = <hostname>;<type>;<short_desc>;<desc>;<owner_user>;<owner_group>;<prot_mask>;<ip_addr>
ug_client_workstation1_data="{{client_hostname}};client;VM Host;Host Workstation;${ug_sysuser_sysroot_name};${ug_sysgrp_admin};755;{{client_ip_addr}};{{client_email}}"

#
# Database Users
#	DB User Data Format:
# 		ug_dbuser_<userid>_data = "<user-name>;<user-password>;<region-role-list>;<host-list>"
#		region-role-list is a comma separated list of <region>:<role> pairs.
#
ug_db_install_user_name=root                            # User ID to do WordPress DB setup
ug_db_install_user_pass="{{root_password}}"            	# User Password to do WordPress DB setup
ug_db_root_remote=                                      # Enable/disable root remote login
ug_db_colocated=1                                       # Databases are server co-located flag (users are same all regions)

ug_dbuser_list=sysroot,sysadmin,sysdev1,sysapp          # List of Database User IDs. One section of detail below for each.

# Root
ug_dbuser_root_name=root
ug_dbuser_root_pass="{{root_password}}"
ug_dbuser_root_hosts="localhost"
if [ $ug_db_root_remote ] ; then
	ug_dbuser_root_hosts="localhost,%.${ug_server_domain}"
	ug_dbuser_list="${ug_dbuser_list},root"
fi
ug_dbuser_root_region_roles="prod:sys,mod:sys,dev:sys"
ug_dbuser_root_data="root;${ug_dbuser_root_pass};${ug_dbuser_root_region_roles};${ug_dbuser_root_hosts}"

# wci Root
ug_dbuser_sysroot_name=mauderoot
ug_dbuser_sysroot_pass="${ug_sysuser_sysroot_pass}"
ug_dbuser_sysroot_region_roles="prod:sys,mod:sys,dev:sys"
ug_dbuser_sysroot_hosts="localhost"
ug_dbuser_sysroot_data="${ug_dbuser_sysroot_name};${ug_dbuser_sysroot_pass};${ug_dbuser_sysroot_region_roles};${ug_dbuser_sysroot_hosts}"

# wci Administrator
ug_dbuser_sysadmin_name=maudeadmin
ug_dbuser_sysadmin_pass="${ug_sysuser_sysadmin_pass}"
ug_dbuser_sysadmin_region_roles="prod:user,mod:app,dev:app"
ug_dbuser_sysadmin_hosts="localhost,%.${ug_server_domain}"
ug_dbuser_sysadmin_data="${ug_dbuser_sysadmin_name};${ug_dbuser_sysadmin_pass};${ug_dbuser_sysadmin_region_roles};${ug_dbuser_sysadmin_hosts}"

# UGX Developer 1
ug_dbuser_sysdev1_name=maudedev1
ug_dbuser_sysdev1_pass="${ug_sysuser_sysdev1_pass}"
ug_dbuser_sysdev1_region_roles="prod:user,mod:user,dev:sys"
ug_dbuser_sysdev1_hosts="localhost,%.${ug_server_domain}"
ug_dbuser_sysdev1_data="${ug_dbuser_sysdev1_name};${ug_dbuser_sysdev1_pass};${ug_dbuser_sysdev1_region_roles};${ug_dbuser_sysdev1_hosts}"

# UGX Application
ug_dbuser_sysapp_name=maudeapp
ug_dbuser_sysapp_pass="${ug_sysuser_sysapp_pass}"
ug_dbuser_sysapp_region_roles="prod:app,mod:app,dev:app"
ug_dbuser_sysapp_hosts="localhost,%.${ug_server_domain}"
ug_dbuser_sysapp_data="${ug_dbuser_sysapp_name};${ug_dbuser_sysapp_pass};${ug_dbuser_sysapp_region_roles};${ug_dbuser_sysapp_hosts}"

# Database Roles
#
#	Defines the privileges for database, tables, functions and procedures for roles.
#
#	System	- full access
#   Dev 	- access to deploy code
#   App 	- access to read and write data
#   User 	- access to read data
#
ug_dbrole_list="sys,dev,app,user"

ug_dbrole_sys_db_privs="ALL PRIVILEGES,GRANT OPTION"
ug_dbrole_dev_db_privs="CREATE ROUTINE,CREATE TEMPORARY TABLES,GRANT OPTION"
ug_dbrole_app_db_privs="CREATE ROUTINE,CREATE TEMPORARY TABLES"
ug_dbrole_user_db_privs=""

ug_dbrole_sys_table_privs="ALL PRIVILEGES,GRANT OPTION"
ug_dbrole_dev_table_privs="ALTER,CREATE,DELETE,DROP,INDEX,INSERT,UPDATE,SELECT"
ug_dbrole_app_table_privs="ALTER,CREATE,DELETE,DROP,INDEX,INSERT,UPDATE,SELECT"
ug_dbrole_user_table_privs="SELECT"

ug_dbrole_sys_function_privs="ALTER ROUTINE,EXECUTE,GRANT OPTION"
ug_dbrole_dev_function_privs="ALTER ROUTINE,EXECUTE,GRANT OPTION"
ug_dbrole_app_function_privs="EXECUTE"
ug_dbrole_user_function_privs=""

ug_dbrole_sys_procedure_privs="ALTER ROUTINE,EXECUTE,GRANT OPTION"
ug_dbrole_dev_procedure_privs="ALTER ROUTINE,EXECUTE,GRANT OPTION"
ug_dbrole_app_procedure_privs="EXECUTE"
ug_dbrole_user_procedure_privs=""

#
# Remote Desktop (TigerVNC)
#
ug_display_geometry="1920x1080"							#Display Geometry
ug_remote_users="sysroot,sysadmin,sysdev1"

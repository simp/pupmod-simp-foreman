# foreman

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the SIMP Foreman module provides](#module-description)
3. [Setup - The basics of getting started with Foreman](#setup)
    * [What Foreman affects](#what-foreman-affects)
    * [Setup Requirements](#setup-requirements)
    * [Beginning with Foreman](#beginning-with-foreman)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A SIMP specific implementation of the Foreman. Designed to be able to incorporate the
Foreman into a previously existing and configured puppet master.

## Module Description

The SIMP Foreman module allows for a functioning Foreman web UI, capable of handling
smart-proxies, LDAP authentication, and user management. Puppet reports are sent to
the foreman reporting tool where they are displayed in the default dashboard.
For this release, only the monitoring based services are being supported.

This module is limited to the above functionality. Currently, support for the
Foreman provisioning software has not been incorporated. In future releases this can
be expected. Initially, however, this module was designed to provide a graphical tool
to monitor Puppet, and specifically SIMP, systems.

NOTE: All aspects of this module are known to work with SELinux in enforcing mode.

## Setup

### What Foreman affects

Services Affected:
* postgresql
* foreman
* foreman-proxy
* httpd

WARNINGS:
* This installation of SIMP Foreman is tied heavily to the ruby-193 Software Collection
* All changes made to the Foreman via the Puppet module will take precedence over any manual
  changes made in the web UI. All manual changes will be overridden on the ensuing Puppet run
  if there is a conflict.

### Setup Requirements

Minimum Requirements:
* 2 CPUs
* 2GB RAM

Repositories:

Some repositories and software collections must be imported to use the Foreman module. They are as follows.

* Foreman - http://yum.theforeman.org/releases/
* Foreman-plugins - http://yum.theforeman.org/plugins/
* V3814 - https://www.softwarecollections.org/en/scls/rhscl/v8314/
* Httpd24 - https://www.softwarecollections.org/en/scls/rhscl/httpd24/
* Ruby 193 - https://www.softwarecollections.org/en/scls/rhscl/ruby193/

### Beginning with Foreman

For basic information on the Foreman, see http://theforeman.org/

In order to setup the Foreman web UI, you'll want to set the following in Hiera:

```
# By default, the admin user password will be autogenerated and nonsensical looking.
# Set that here if you wish to have control over it.
foreman::admin_password : 'No one will ever hack this!'

# These are the hosts that will connect to your Foreman proxy. You'll want to make sure
# all hosts who are reporting to Foreman appear here.
foreman::proxy::trusted_hosts :
  - your.first.host
  - your.second.host
  - your.nth.host

# Make sure reporting is turned on in Puppet!
pupmod::report : true

# Obviously include all other necessary classes for this host. This is only to show
# some sample site data you may wish to have. If the default configuration works for you,
# then this won't be needed.
classes:
  - foreman
  - site::foreman
```

If you wish to be able to add users to connect via an LDAP server, add the following
code to something like site::foreman.pp

```
# This class assumes foreman has already been included somewhere. Add 'include foreman'
# as the first line inside of the class if that is not true.
class site::foreman {

  # Adds an LDAP authentication source to Foreman. This assumes this authentication source
  # is LDAP and already exists. By default, this define will
  foreman::auth_source { 'my_awesome_ldap_server':
    server => $::fqdn
  }

  foreman::user { 'amazing.user':
    auth_source => 'my_awesome_ldap_server',
    web_admin   => true,
    firstname   => 'Amazing',
    lastname    => 'User'
  }

  foreman::user { 'untrustworth.user':
    auth_source => 'my_awesome_ldap_server',
    web_admin   => false, # This is the default, but want to show the difference from above.
    firstname   => 'Untrustworthy',
    lastname    => 'User'
  }
}
```

And voila! Here is your working Foreman instance complete with LDAP authentication and
users to login.

## Usage

Foreman classes:
* foreman
* foreman::params
* foreman::passenger
* foreman::proxy
* foreman::proxy::facts
* foreman::proxy::puppet
* foreman::proxy::puppetca
* foreman::ssl

Foreman defines:
* foreman::auth_source
* foreman::smart_proxy
* foreman::user

Custom Types:
* foreman_auth_source
* foreman_user
* foreman_smart_proxy

Facts Used:
* domain
* fqdn
* hostname

## Reference


## Limitations

Supported Operating Systems:
* RHEL 6.6/7.0
* CentOS 6.6/7.0

Supported Puppet Versions:
* Puppet 3.7
* Puppet 4.0

Supported Configuration Data Tools
* Hiera

## Development

If you would like to contribute to the SIMP Foreman module, please
contact the SIMP team with patches, ideas, and suggestions.

## Release Notes/Contributors/Etc

Release Notes:

For all SIMP foreman release notes, please see the RPM changelog.

Initial Contributors:

* Kendall Moore <kmoore@keywcorp.com>
* Trevor Vaughan <tvaughan@onyxpoint.com>
* Chris Tessmer <ctessmer@onyxpoint.com>
* Jacob Gingrich <jgingrich@onyxpoint.com>
* Nick Markowski <nmarkowski@keywcorp.com>
* Michael Riddle <mriddle@onyxpoint.com>
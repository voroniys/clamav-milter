clamav-milter Cookbook
======================
[![Build Status](https://travis-ci.org/voroniys/clamav-milter.svg?branch=master)](https://travis-ci.org/voroniys/clamav-milter)
[![Cookbook Version](https://img.shields.io/cookbook/v/clamav-milter.svg)](https://supermarket.chef.io/cookbooks/clamav-milter)

The cookbook is to install and configure 3 components of Clamav antivirus mail checker - clamav-milter. In order to make it working it install Clamav daemon and Clamav virus database updater as well.

#### packages
- `clamav` - the common part of all Clamav components
- `clamav-daemon` - the Clamav daemon package
- `clamav-milter` - Milter itself to check passing e-mail

Attributes
----------
The configuration for all 3 components located in 3 hash arrays:

    default['clamav']['config']['clamd']
    default['clamav']['config']['freshclam']
    default['clamav']['config']['clamav-milter']

As members in these hashes any configuration directives are allowed. They will be 1:1 placed in config files.
For instance the example of configuration within the Chef role:

```json
  "override_attributes": {
    "clamav": {
      "config": {
        "clamd": {
          "LogSyslog": "false",
          "LogFile": "/var/log/clamav/clamav.log",
          "LogTime": "true",
          "LogFileUnlock": "false",
          "LogFileMaxSize": "1M"
        },
        "freshclam": {
          "LogSyslog": "false",
          "UpdateLogFile": "/var/log/clamav/freshclam.log",
          "LogTime": "true",
          "LogFileMaxSize": "100M"
        },
        "milter": {
          "OnClean": "Accept",
          "OnInfected": "Reject",
          "OnFail": "Defer",
          "AddHeader": "Replace",
          "LogSyslog": "false",
          "LogVerbose": "false",
          "LogInfected": "Off",
          "LogClean": "Off",
          "LogRotate": "true",
          "LogFile": "/var/log/clamav/clamav-milter.log",
          "LogTime": "true",
          "LogFileUnlock": "false",
          "LogFileMaxSize": "1M"
        }
      }
    }
  }
```
Default attributes are good enough to start sevices without any configuration.


Usage
-----
#### clamav-milter::default
Just include `clamav-milter` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[clamav-milter]"
  ]
}
```

Contributing
------------

Any improvements and/or fixes are welcome. 

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github


License and Authors
-------------------

Authors: Stanislav Voroniy 

Copyright 2015, Stanislav Voroniy

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


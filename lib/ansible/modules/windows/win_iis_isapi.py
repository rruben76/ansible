#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2018, Richard Ruben (richard.ruben@gmail.com)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = r'''
---
module: win_iis_isapi
version_added: "2.7"
short_description: Configures a ISAPI restriction in IIS
description:
     - Creates, Removes and configures a ISAPI/CGI restriction in IIS
options:
  extensionpath:
    description:
      - The physical path of the extension that will be added/removed 
      - The specified file must exist.
    required: yes
  state:
    description:
      - Whether to add or remove the specified virtual directory.
    choices: [ absent, present ]
    default: present
  allowed:
    description:
      - Indicate if the ISAPI/CGI extension will be enabled 
    default: True  
author:
- Richard Ruben
'''

EXAMPLES = r'''
- name: Add and Enable .NET Framework 4.0 ISAPI Extension 
  win_iis_isapi:
    allowed: true
    state: present
    extesionpath: $env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll"

- name: Add if not present and Disable .NET Framework 4.0 ISAPI Extension 
  win_iis_isapi:
    allowed: false
    state: present
    extesionpath: $env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll"

- name: Remove .NET Framework 4.0 ISAPI Extension 
  win_iis_isapi:    
    state: absent
    extesionpath: $env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll"
'''

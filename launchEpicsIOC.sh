#!/usr/bin/env bash

if [ -z $EPICS_BASE ]; then
   source ~/code/EPICS/loadEPICS.sh
fi


/home/kyrsjo/code/EPICS/synApps_6_2/support/areaDetector-R3-10/aravisGigE/iocs/aravisGigEIOC/bin/linux-x86_64/aravisGigEApp st.cmd

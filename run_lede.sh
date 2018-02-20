#docker network create -d bridge --subnet 172.25.1.0/24 isolated_nw
docker rm lede1 --force
docker run -it --privileged -d  --name lede1 interbeing/vcpe_lede 
#docker exec -it lede1 bin/ash -c '/etc/init.d/supervisord start'
#docker run -it -d --privileged -v /lib/modules:/lib/modules:ro -p 8124:8123 --env ROOT_PASSWORD=MyRootPW123 --env CANALBOX_SN=andy013 --env CORE='120.55.58.18' --env FRP_SSH_PORT=6213 --env FRP_POLIPO_PORT=6313 --name lede1  interbeing/vcpe_lede  
#docker exec -it vcpe1 bin/ash -c 'echo "$CANALBOX_SN" > /usr/local/etc/vnet/sn'
#docker exec -it vcpe1 bin/ash -c 'echo "$CORE" core >> /etc/hosts'
#docker exec -it vcpe1 bin/ash -c 'sed -i "s/6210/"$FRP_SSH_PORT"/g" /etc/frpc.ini'
#docker exec -it vcpe1 bin/ash -c 'sed -i "s/6310/"$FRP_POLIPO_PORT"/g" /etc/frpc.ini'
#docker exec -it vcpe1 bin/ash -c 'supervisord -c /etc/supervisord.conf '

function get_vap(){
vap=`docker exec -it vcpe1 bin/ash -c 'ipsec status' | grep ROUTED | awk '{print $1}'  | cut -d '{' -f 1`
echo waiting for vap to come up ,now vap is $vap
sleep 1
}

function restart_ipsec() {
get_vap
if [[ $vap = *"vap-"* ]] ; then
	echo vap has been created with name $vap
	docker exec -it vcpe1 bin/ash -c 'ipsec restart'
	sleep 1
	docker exec -it vcpe1 bin/ash -c 'ipsec up '$vap''
fi
}

#get_vap
#until  [[ $vap = *"vap-"* ]] ; do
#	restart_ipsec
#         done



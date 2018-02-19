docker stop vcpe1
docker rm vcpe1
docker network create -d bridge --subnet 172.25.1.24/ isolated_nw
docker run -it -d --privileged -v /lib/modules:/lib/modules:ro -p 8123:8123 --name vcpe1 --network isolated_nw interbeing/vcpe /bin/ash 
docker exec -it vcpe1 bin/ash -c 'echo andy011 > /usr/local/etc/vnet/sn'
docker exec -it vcpe1 bin/ash -c 'echo 120.55.58.18 core >> /etc/hosts'
docker exec -it vcpe1 bin/ash -c 'supervisord -c /etc/supervisord.conf '

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

get_vap
until  [[ $vap = *"vap-"* ]] ; do
	restart_ipsec
         done



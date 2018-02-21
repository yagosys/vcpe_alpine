read -p "input your sn? " sn 
id="${sn: -2}"
echo $id
os='alpine'

docker rm $os$sn --force
docker network rm isolated_nw_$id
docker network create -d bridge --subnet 172.1.$id.0/24 isolated_nw_$id
docker run -it -d --privileged --cap-add=ALL --network=isolated_nw_$id -v /lib/modules:/lib/modules:ro -p 81$id:8123 --env ROOT_PASSWORD=MyRootPW123 --env CANALBOX_SN=$sn --env CORE='120.55.58.18' --env FRP_SSH_PORT=62$id --env FRP_POLIPO_PORT=63$id --name $os$sn  interbeing/vcpe_$os
docker exec -it $os$sn bin/sh -c 'echo "$CANALBOX_SN" > /usr/local/etc/vnet/sn'
docker exec -it $os$sn bin/sh -c 'echo "$CORE" core >> /etc/hosts'
docker exec -it $os$sn bin/sh -c 'service ipsec start'
docker exec -it $os$sn bin/sh -c 'sed -i "s/6210/"$FRP_SSH_PORT"/g" /etc/frpc.ini'
docker exec -it $os$sn bin/sh -c 'sed -i "s/6310/"$FRP_POLIPO_PORT"/g" /etc/frpc.ini'
docker exec -it $os$sn bin/sh -c 'sed -i "s/172.17.0.2/172.1.'$id'.2/g" /etc/canalbox.conf'
docker exec -it $os$sn bin/sh -c 'sed -i "s/172.17.0.1/172.1.'$id'.1/g" /etc/canalbox.conf'




function get_vap(){
vap=`docker exec -it $os$sn bin/sh -c 'ipsec status' | grep ROUTED | awk '{print $1}'  | cut -d '{' -f 1`
echo waiting for vap to come up ,now vap is $vap
sleep 1
}

function restart_ipsec() {
get_vap
if [[ $vap = *"vap-"* ]] ; then
	echo vap has been created with name $vap
	docker exec -it $os$sn bin/sh -c 'ipsec restart'
	sleep 1
	docker exec -it $os$sn bin/sh -c 'ipsec up '$vap''
fi
}

get_vap
until  [[ $vap = *"vap-"* ]] ; do
	restart_ipsec
         done



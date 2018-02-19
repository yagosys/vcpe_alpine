docker stop vcpe1
docker rm vcpe1
docker network create -d bridge --subnet 172.25.1.24/ isolated_nw
docker run -it -d --privileged -v /lib/modules:/lib/modules:ro -p 8123:8123 --name vcpe1 --network isolated_nw interbeing/vcpe /bin/ash 
docker exec -it vcpe1 bin/ash -c 'echo 'input your sn' > /usr/local/etc/vnet/sn'
docker exec -it vcpe1 bin/ash -c 'echo 127.0.0.1 core >> /etc/hosts'
docker exec -it vcpe1 bin/ash -c 'supervisord -c /etc/supervisord.conf '
docker exec -it vcpe1 bin/ash -c 'ipsec start'
sleep 1
vap=`docker exec -it vcpe1 bin/ash -c 'ipsec status' | grep ROUTED | awk '{print $1}'  | cut -d '{' -f 1`
echo vap is $vap ----before restart ipsec
docker exec -it vcpe1 bin/ash -c 'ipsec up '$vap''
docker exec -it vcpe1 bin/ash -c 'ipsec restart'
echo vap is $vap ----after restart ipsec 
docker exec -it vcpe1 bin/ash -c 'ipsec up '$vap''



COUNT=0
option=''
 for i in $(ip link show |  sed -n '1p; 3p' | cut -d ':' -f2)
do
       COUNT=$[COUNT+1]
       TAB_NETWORKS[$COUNT]=$i
       option="$option $COUNT $i"
done

IDNETWORK=$(\
whiptail --title "NETWORK INTERFACE Choice"\
 --menu "choose on which network you want to launch the analysis : "  20 70 10 \
 $option 3>&1 1>&2 2>&3 3>&- )


#echo "${TAB_NETWORKS[$IDNETWORK]}"
#ip address show dev ${TAB_NETWORKS[$IDNETWORK]}
Mask=$(ip a s dev wlp1s0 | awk '/inet /{print $2 }' | cut -d '/' -f2 | sed -n "1p;")
HOST_IP=$(ip a s dev wlp1s0 | awk '/inet /{print $2 }' | cut -d '/' -f1 | sed -n "1p;")

Bytes_1=$(echo $HOST_IP | cut -d '.' -f1)
Bytes_2=$(echo $HOST_IP | cut -d '.' -f2)
Bytes_3=$(echo $HOST_IP | cut -d '.' -f3)

if [ $Mask = "8" ];then
    NETWORK="$Bytes_1.0.0.0"
elif [ $Mask = "16" ];then
    NETWORK="$Bytes_1.$Bytes_2.0.0"
elif [ $Mask = "24" ];then
    NETWORK="$Bytes_1.$Bytes_2.$Bytes_3.0"
else
    echo "error only mask in /8, /16, /24 are take in this script "
fi

nmap -sP "$NETWORK/$Mask" | awk '/Nmap /{print $5 }' | head -n -1 | awk 'NR != 1' #give hostname of device who connect on the network
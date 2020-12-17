if [ ! -d ~/backup ]; then
    mkdir ~/backup
    echo "Created backup directory at ~/backup"
else
    echo "~/backup directory already exists"
fi

# unload, backup and remove original modules

if [ ! -f /etc/modprobe.d/blacklist.conf ]; then
    sudo touch /etc/modprobe.d/blacklist.conf
else
    echo "/etc/modprobe.d/blacklist.conf already exists"
fi

blacklisted=$(cat /etc/modprobe.d/blacklist.conf | sed -n "/blacklist mwifiex_pcie/p" | wc -l)
if [ $blacklisted -gt 0 ]; then
    echo "mwifiex_pcie already blacklisted"
else
    cat /etc/modprobe.d/blacklist.conf | sed -n "/blacklist mwifiex_pcie/p" | wc -l
    echo "Blacklisted mwifiex_pcie"
fi
sudo modprobe -r mwifiex_pcie
sudo modprobe -r mwifiex
sudo modprobe -r mac80211
sudo modprobe -r cfg80211

mpath=/lib/modules/4.9.140+/kernel/net/wireless/cfg80211.ko
if [ ! -f $mpath ]; then
    echo "$mpath does not exist"
else
    sudo mv $mpath ~/backup/
    echo "Backed-up $mpath"
fi

mpath=/lib/modules/4.9.140+/kernel/net/mac80211/mac80211.ko
if [ ! -f $mpath ]; then
    echo "$mpath does not exist"
else
    sudo mv $mpath ~/backup/
    echo "Backed-up $mpath"
fi

mpath=/lib/modules/4.9.140-tegra/kernel/net/wireless/cfg80211.ko
if [ ! -f $mpath ]; then
    echo "$mpath does not exist"
else
    sudo mv $mpath ~/backup/
    echo "Backed-up $mpath"
fi

mpath=/lib/modules/4.9.140-tegra/kernel/net/mac80211/mac80211.ko
if [ ! -f $mpath ]; then
    echo "$mpath does not exist"
else
    sudo mv $mpath ~/backup/
    echo "Backed-up $mpath"
fi

# install Laird and updated modules
# install Laird and updated modules
trgpath=/lib/modules/4.9.140-tegra
if [ -d $trgpath ]; then
    sudo cp compat.ko cfg80211.ko mac80211.ko lrdmwl.ko lrdmwl_pcie.ko $trgpath/
fi

trgpath=/lib/modules/4.9.140+
if [ -d $trgpath ]; then
    sudo cp compat.ko cfg80211.ko mac80211.ko lrdmwl.ko lrdmwl_pcie.ko $trgpath/
fi

sudo cp -R lrdmwl /lib/firmware/

sudo depmod -a

sudo modprobe compat
sudo modprobe cfg80211
sudo modprobe mac80211
sudo modprobe lrdmwl
sudo modprobe lrdmwl_pcie

# !!! power cycle Xavier (not just reboot) !!!

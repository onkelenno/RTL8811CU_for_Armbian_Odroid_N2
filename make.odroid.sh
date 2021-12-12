#!/bin/bash

. /etc/armbian-release

apt update
apt purge network-manager
apt install git build-essential linux-headers-$BRANCH-$LINUXFAMILY usb-modeswitch
apt clean

pushd /usr/src/linux-headers-$(uname -r)/scripts/ || exit 1
make recordmcount
popd || exit 2

cp /lib/modules/$(uname -r)/build/arch/arm64/Makefile /lib/modules/$(uname -r)/build/arch/arm64/Makefile.$(date +%Y%m%d%H%M)
sed -i 's/-mgeneral-regs-only//' /lib/modules/$(uname -r)/build/arch/arm64/Makefile

sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM_RPI = y/CONFIG_PLATFORM_ARM_RPI = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM64_RPI = n/CONFIG_PLATFORM_ARM64_RPI = y/g' Makefile
sed -i 's/#ifdef CONFIG_AMLOGIC_DEBUG_LOCKUP/#ifndef CONFIG_AMLOGIC_DEBUG_LOCKUP/g' /usr/src/linux-headers-$(uname -r)/arch/arm64/include/asm/irqflags.h

make
make install

echo "Load driver:     modprobe 8821cu"
echo "Switch PenDrive: usb_modeswitch -K -v 0bda -p 1a2b"
echo
echo "Test:"
echo "Scan Networks:   iwlist wlan0 scan"
echo "Get IP:          dhclient wlan0"
echo
echo "If everythings worked without errors, please reboot!"
echo "Packages can be removed then:"
echo " apt purge linux-headers-$BRANCH-$LINUXFAMILY"

#!/system/bin/sh

setenforce 0

ret=255
until [ $ret == 0 ]
do
	mount -o rw,remount /
	ret=$?	
done

ret=255
until [ $ret == 0 ]
do
	mount -o rw,remount /system
	ret=$?	
done

ret=255
until [ $ret == 0 ]
do
	mount -o rw,remount /data
	ret=$?	
done

while  [ `getenforce` != "Permissive" ]
	do
	setenforce 0	
done

chmod -R 777 /system/etc/init.d
chmod 777 /system/etc/init.d
run-parts /system/etc/init.d/

.PHONY: default

CA_PASSWORD:=dev-root-password

default: all

clean:
	rm -rf root-ca/

root-ca/cacert.pem:
	echo $(CA_PASSWORD)
	mkdir -p root-ca/private root-ca/newcerts
	cp templates/root-ca.conf root-ca/ca.conf
	touch root-ca/certindex.txt
	echo 00 > root-ca/serial
	cd root-ca; CA_PASSWORD="$(CA_PASSWORD)" openssl req -new -x509 -extensions v3_ca -keyout private/cakey.pem -out cacert.pem -days 90 -config ./ca.conf -passout env:CA_PASSWORD -batch

all: root-ca/cacert.pem

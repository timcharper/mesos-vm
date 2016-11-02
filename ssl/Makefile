.PHONY: default

CA_PASSWORD:=dev-root-password

default: all

super-clean:
	rm -rf root-ca/
clean:
	rm -rf root-ca/serial root-ca/certindex.txt root-ca/newcerts root-ca/certs root-ca/

root-ca/cacert.pem:
	mkdir -p root-ca
	CA_PASSWORD="$(CA_PASSWORD)" openssl req -new -x509 -extensions v3_ca -keyout root-ca/cakey.pem -out root-ca/cacert.pem -days 90 -config templates/root-ca.conf -passout env:CA_PASSWORD -batch

certs: root-ca/cacert.pem
	mkdir -p certs/private certs/newcerts
	ln -sf ../templates/root-ca.conf certs/ca.conf
	touch certs/certindex.txt
	echo 00 > certs/serial
	ln -sf ../root-ca/cacert.pem certs/cacert.pem
	ln -sf ../../root-ca/cakey.pem certs/private/cakey.pem

certs/mesos.dev.vagrant.csr: certs
	cd certs; CA_PASSWORD="$(CA_PASSWORD)" openssl req -new -days 90 -config ../templates/mesos.dev.vagrant.conf -passout env:CA_PASSWORD  -out ../$@

certs/mesos.dev.vagrant.crt: certs/mesos.dev.vagrant.csr
	cd certs; yes | CA_PASSWORD="$(CA_PASSWORD)" openssl ca -config ca.conf -in mesos.dev.vagrant.csr -passin env:CA_PASSWORD

all: root-ca/cacert.pem root-ca/mesos.dev.vagrant.csr

.PHONY: default
.SECONDARY:

CA_PASSWORD:=dev-root-password

default: all

super-clean:
	rm -rf root-ca/
clean:
	rm -rf certs pillar

root-ca/cacert.pem:
	mkdir -p root-ca
	CA_PASSWORD="$(CA_PASSWORD)" openssl req -new -x509 -extensions v3_ca -keyout root-ca/cakey.pem -out root-ca/cacert.pem -days 90 -config templates/root-ca.conf -passout env:CA_PASSWORD -batch

certs: root-ca/cacert.pem
	mkdir -p certs/private certs/newcerts certs/certs
	ln -sf ../templates/root-ca.conf certs/ca.conf
	touch certs/certindex.txt
	echo 00 > certs/serial
	ln -sf ../root-ca/cacert.pem certs/cacert.pem
	ln -sf ../../root-ca/cakey.pem certs/private/cakey.pem

certs/%.csr: certs
	openssl genrsa  -out certs/$*.key 1024
	cd certs; CA_PASSWORD="" openssl req -key $*.key -new -days 90 -config ../templates/$*.conf -out ../$@

certs/%.crt: certs/%.csr
	cd certs; yes | CA_PASSWORD="$(CA_PASSWORD)" openssl ca -config ca.conf -in $*.csr -passin env:CA_PASSWORD -notext
	mv certs/newcerts/* certs/certs
	ln -sf certs/$$(tail -n 1 certs/certindex.txt | awk '{print $$3}').pem certs/$*.crt

pillar/%.sls: certs/%.crt
	mkdir -p pillar
	echo "$*.key: |" > $@
	cat certs/$*.key | bin/ws-indent 2 >> $@
	echo "$*.crt: |" >> $@
	cat certs/$*.crt | bin/ws-indent 2 >> $@

all: root-ca/cacert.pem pillar/mesos.dev.vagrant.sls

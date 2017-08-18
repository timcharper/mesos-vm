.PHONY: default clean super-clean
.SECONDARY:

CA_PASSWORD:=dev-root-password

default: all

super-clean: | clean
	rm -rf root-ca/
clean:
	rm -rf certs pillar

root-ca/cacert.pem:
	mkdir -p root-ca
	CA_PASSWORD="$(CA_PASSWORD)" openssl req -new -x509 -extensions v3_ca -keyout root-ca/cakey.pem -out root-ca/cacert.pem -days 90 -config templates/root-ca.conf -passout env:CA_PASSWORD -batch

certs/init: root-ca/cacert.pem
	mkdir -p certs/private certs/newcerts certs/certs
	ln -sf ../templates/root-ca.conf certs/ca.conf
	touch certs/certindex.txt
	echo 00 > certs/serial
	ln -sf ../root-ca/cacert.pem certs/cacert.pem
	ln -sf ../../root-ca/cakey.pem certs/private/cakey.pem
	touch $@

certs/%.csr: certs/init
	openssl genrsa  -out certs/$*.key 1024
	cd certs; CA_PASSWORD="" openssl req -key $*.key -new -days 90 -config ../templates/$*.conf -out ../$@

certs/%.crt: certs/%.csr
	cd certs; yes | CA_PASSWORD="$(CA_PASSWORD)" openssl ca -config ca.conf -in $*.csr -passin env:CA_PASSWORD -notext -extensions v3_req
	mv certs/newcerts/* certs/certs
	ln -sf certs/$$(tail -n 1 certs/certindex.txt | awk '{print $$3}').pem certs/$*.crt

../srv/pillar/secrets/%-cert.sls: certs/%.dev.vagrant.crt
	mkdir -p pillar
	echo "$*:" > $@
	echo "  $*.dev.vagrant.key: |" >> $@
	cat certs/$*.dev.vagrant.key | bin/ws-indent 4 >> $@
	echo "  $*.dev.vagrant.crt: |" >> $@
	cat certs/$*.dev.vagrant.crt | bin/ws-indent 4 >> $@

certs/%.jks: certs/%.crt
	JKS_PASS="$(CA_PASSWORD)" openssl pkcs12 -inkey certs/$*.key -name $* -in certs/$*.crt -chain -CAfile certs/cacert.pem -export -out certs/$*.pkcs12 -password "env:JKS_PASS"
	keytool -importkeystore -srckeystore certs/$*.pkcs12 -srcalias $* -srcstorepass "$(CA_PASSWORD)" -srcstoretype PKCS12 -destkeystore certs/$*.jks -deststorepass "$(CA_PASSWORD)"

certs/cacert.jks:
	yes | keytool -import -file certs/cacert.pem -alias dev-root-ca -keystore certs/cacert.jks -deststorepass "default"

../srv/pillar/secrets/cacert.sls: certs/cacert.pem
	mkdir -p pillar
	echo "cacert.crt: |" > $@
	cat certs/cacert.pem | bin/ws-indent 2 >> $@

all: root-ca/cacert.pem ../srv/pillar/secrets/mesos-cert.sls ../srv/pillar/secrets/ceph-cert.sls certs/ceph.dev.vagrant.jks certs/cacert.jks ../srv/pillar/secrets/cacert.sls

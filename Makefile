init: 
	@if [ -d files ];\
	 then echo "files dir exists";\
	 else mkdir files;\
	fi
	@if [ -d files/kendryte-standalone-sdk ];\
	 then echo "kendryte-standalone-sdk in files";\
	 else git clone https://github.com/kendryte/kendryte-standalone-sdk files/kendryte-standalone-sdk;\
	fi

build:
	docker build -t k210_sdk_standalone:1.0 -f Dockerfile .

interactive: init 
	docker run -e DISPLAY=$(shell ipconfig getifaddr en0):0 \
				--privileged \
				-v /dev/tty.usbserial-294E40D9B50:/dev/tty.usbserial-294E40D9B50 \
				-v /dev/tty.usbserial-294E40D9B51:/dev/tty.usbserial-294E40D9B51 \
				--mount type=bind,source=$(shell pwd)/files,target=/home/sdkuser \
				-it k210_sdk_standalone:1.0

attach:
	docker exec -it $(shell docker ps -lq) bash 
	

# template: init
# 	docker run -e DISPLAY=192.168.8.216:0 \
# 				--privileged \
# 				-v /dev/tty.usbmodem1432301:/dev/tty.usbmodem1432301 \
# 				--mount type=bind,source=$(shell pwd)/files,target=/home/fpgauser/ \
# 				--entrypoint /usr/local/src/build_apio_template.sh \
# 				-it vesc-dev:1.0

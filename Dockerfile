FROM registry.docker-cn.com/library/ubuntu:16.04

COPY build/java_policy /etc

RUN buildDeps='software-properties-common git libtool cmake python-dev python3-pip python-pip libseccomp-dev wget' && \
    apt-get update && apt-get install -y python python3.5 python-pkg-resources python3-pkg-resources gcc g++ $buildDeps && \
    add-apt-repository ppa:openjdk-r/ppa && apt-get update && apt-get install -y openjdk-8-jdk && \
	apt-get install -y nodejs && \
	cd /tmp && wget http://launchpadlibrarian.net/371512681/libtinfo6_6.1+20180210-4ubuntu1_amd64.deb && wget http://launchpadlibrarian.net/373832437/chezscheme9.5_9.5+dfsg-5_amd64.deb && apt-get install ./libtinfo6_6.1+20180210-4ubuntu1_amd64.deb && apt-get install ./chezscheme9.5_9.5+dfsg-5_amd64.deb && mv /usr/bin/chezscheme9.5 /usr/bin/scheme && rm ./* && \
	cd /tmp && git clone --depth 1 https://github.com/pocmo/Python-Brainfuck.git && mv Python-Brainfuck /usr/bin/brainfuck && \
    pip3 install --no-cache-dir psutil gunicorn flask requests && \
    cd /tmp && git clone -b newnew  --depth 1 https://github.com/QingdaoU/Judger && cd Judger && \ 
    mkdir build && cd build && cmake .. && make && make install && cd ../bindings/Python && python3 setup.py install && \
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /code && \
    useradd -u 12001 compiler && useradd -u 12002 code && useradd -u 12003 spj && usermod -a -G code spj

HEALTHCHECK --interval=5s --retries=3 CMD python3 /code/service.py
ADD server /code
WORKDIR /code
EXPOSE 8080
ENTRYPOINT /code/entrypoint.sh

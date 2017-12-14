FROM        debian

MAINTAINER  Shaker Qawasmi "http://github.com/sqawasmi"

# Update the package repository
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \ 
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl locales git python python-pip python-dev libxml2-dev libxslt-dev zlib1g-dev

# Configure locale
RUN export LANGUAGE=en_US.UTF-8 && \
	export LANG=en_US.UTF-8 && \
	export LC_ALL=en_US.UTF-8 && \
	locale-gen en_US.UTF-8 && \
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Install readthedocs
RUN mkdir /www/ && cd /www/ && git clone https://github.com/rtfd/readthedocs.org.git
RUN ln -sf /usr/pip2 /usr/local/bin/pip
RUN pip install --upgrade pip
RUN cd /www/readthedocs.org/ && pip install -r requirements.txt
#RUN cd /www/readthedocs.org/ && ./manage.py migrate --noinput
RUN cd /www/readthedocs.org/ && ./manage.py migrate 
RUN cd /www/readthedocs.org/ && echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@localhost', 'admin')" | ./manage.py shell

# Install supervisord
RUN pip install supervisor
ADD files/supervisord.conf /etc/supervisord.conf

CMD ["supervisord"]

FROM debian:buster

USER root

RUN apt-get update

RUN apt-get install -y build-essential wget python3-dev python3-venv python3-wheel curl git

RUN apt-get install -y libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev \
    node-less libjpeg-dev zlib1g-dev libpq-dev libxslt1-dev libldap2-dev libtiff5-dev libjpeg62-turbo-dev\
    libopenjp2-7-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev

# install wkhtmltopdf
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install odoo
RUN git clone https://www.github.com/odoo/odoo --depth 1 --branch 15.0 /opt/odoo/odoo

# Enable virtual env
ENV VIRTUAL_ENV=/opt/odoo/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR /opt/odoo

# Install Odoo dependencies
RUN pip install wheel \
    pip install -r odoo/requirements.txt

COPY ./odoo.conf /etc/odoo/

RUN mkdir -p /mnt/extra-addons 

VOLUME [ "/var/lib/odoo", "/mnt/extra-addons" ]

EXPOSE 8069

CMD [ "/opt/odoo/odoo/odoo-bin",  "-c", "/etc/odoo/odoo.conf"]
FROM python:3.6-alpine

COPY . /kpin/
RUN pip3 install -r /kpin/requirements

ENTRYPOINT ["/kpin/kpin"]

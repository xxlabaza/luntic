
FROM        alpine:3.6
MAINTAINER  Artem Labazin <xxlabaza@gmail.com>

COPY build/docker/luntic /luntic

ENTRYPOINT ["/luntic"]
CMD ["--debug", "0.0.0.0"]

#devops-training

FROM nginx

LABEL maintainer="OlivierKouokam (kouokamcarl@gmail.com)"

#RUN apt-get update && \
#    apt-get upgrade -y && \
#    apt-get install -y curl && \
#    apt-get install -y git
RUN apt-get update && apt-get upgrade -y && apt-get install -y curl && apt-get install -y git

EXPOSE 80

RUN rm -Rf /usr/share/nginx/html/*

RUN git clone https://github.com/diranetafen/static-website-example.git /usr/share/nginx/html

ENTRYPOINT ["nginx", "-g", "daemon off;"]

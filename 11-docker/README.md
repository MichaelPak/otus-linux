11-docker
===

|Backend|Frontend|
|---|---|
|[![](https://images.microbadger.com/badges/image/michaelpak/otus-docker-back.svg)](https://microbadger.com/images/michaelpak/otus-docker-back)|[![](https://images.microbadger.com/badges/image/michaelpak/otus-docker-front.svg)](https://microbadger.com/images/michaelpak/otus-docker-front)|
|[![](https://images.microbadger.com/badges/version/michaelpak/otus-docker-back.svg)](https://microbadger.com/images/michaelpak/otus-docker-back)|[![](https://images.microbadger.com/badges/version/michaelpak/otus-docker-front.svg)](https://microbadger.com/images/michaelpak/otus-docker-front)|

```bash
$ docker build -f back/Dockerfile -t michaelpak/otus-docker-back .
$ docker build -f front/Dockerfile -t michaelpak/otus-docker-front .
$ docker-compose up -d

$ curl localhost
<h1>Hi, Otus Linux! I'm frontend.</h1>

$ curl localhost/back
<h1>Hi, Otus Linux! I'm backend.</h1>
``` 




# SinatraFly

A very simple app (using [Sinatra](http://sinatrarb.com)) and dragonfly to resize existing (publicly accessible) images based on the URL.

This site should _only_ be used behind a CDN. That way the the images are only resized once.


## Setup

```
git clone git@github.com:andycroll/sinatra-fly.git
cd sinatra-fly
```

Set an environment variable 'BASE_URL' (in `.env` in development). This is the only domain that can be a source for images.


## Use

This app expects urls in the format:

`appname.herokuapp.com/400x/path/on/source/domain/image.jpg`
`appname.herokuapp.com/x400/path/on/source/domain/image.jpg`
`appname.herokuapp.com/400x300/path/on/source/domain/image.jpg`


## Run Locally

```
bundle
foreman start
```

The site will be available at [localhost:5000](http://localhost:5000/).

The root path will show an 'Alive' message.


## Deploy

This app should _only_ be deployed with a CDN in front of the application to make a solid use of caching. The resized images will **not** be cached by this app.

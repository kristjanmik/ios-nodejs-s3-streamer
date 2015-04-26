var fs = require('fs');
var uuid = require('uuid');
var express = require('express');
var app = express();
var AWS = require('aws-sdk');
var compress = require('compression');

app.use(compress()); //GZip
app.enable('trust proxy');
app.disable('x-powered-by'); //For security
app.set('json spaces', 0);

AWS.config.accessKeyId = process.env.ACCESSKEY || 'YOURACCESSKEY';
AWS.config.secretAccessKey = process.env.SECRETKEY || 'YOURSECRET';
var bucket = process.env.BUCKET || 'YOURBUCKETNAME';

var s3 = new AWS.S3({params: {Bucket: bucket}});

app.post('/upload',function(req,res){
  var apiKey = req.headers['app-apikey'];

  console.log('Got apiKey',apiKey);

  //Pause the upload and validate
  req.pause();

  //Do some validation with your datastore
  if(apiKey !== 'abcdefg'){
    return res.status(401).json({
      error: 'Not authenticated'
    });
  }

  var uniqueId = uuid.v4(); //Random seed

  if(req.headers['content-type'] !== 'image/png'){
    return res.status(400).json({
      error: 'Wrong content-type'
    });
  }

  if(parseInt(req.headers['content-length']) === 0){
    console.error('No content given');
    return res.status(500).json({
      error: 'No content given'
    });
  }

  var s3Path = 'somefolder/' + uniqueId + '.png';
  s3.upload({
    Body: req, //This is the actual pipe
    ContentType: 'image/png',
    Key: s3Path
  }).on('httpUploadProgress', function(evt) {
    console.log('PROCESS',evt); 
  }).send(function(error, data) { 
    if(error){
      return res.status(500).json({
        error: 'Unable to upload media'
      });
    }
    //All is done!
    //Store the uniqueId somewhere

    console.log('Done!','File stored at',s3Path);
    
    return res.json({
      message: 'upload was succesful'
    });
  });
});

app.listen(3200,function(){
  console.log('Listening on port',3200);
});
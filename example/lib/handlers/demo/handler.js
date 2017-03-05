'use strict'

const spawn = require('child_process').spawn
const fs = require('fs')
const path = require('path')
const AWS = require('aws-sdk')
const tmp = require('tmp')

const S3_UPLOAD_BUCKET = process.env.S3_UPLOAD_BUCKET || 'lambda-xvfb'

module.exports.execute = function (event, context, callback) {
  console.log('event: ', JSON.stringify(event))
  console.log('context: ', JSON.stringify(context))
  const fileName = tmp.tmpNameSync({postfix: '.mp4'})
  console.log('fileName: ', fileName)
  const binDir = path.join(__dirname, '../../../bin')
  console.log('binDir: ', binDir)
  const cmd = path.join(binDir, 'run.sh')
  const args = [
    fileName
  ]
  const envPath = `${binDir}:${process.env.PATH}`
  const LD_LIBRARY_PATH = `${binDir}/lib:${process.env.LD_LIBRARY_PATH}`
  const newEnv = Object.assign({}, process.env, {
    // HOME: targetDir,
    PATH: envPath,
    LD_LIBRARY_PATH,
    TMPDIR: '/tmp'
  })
  const opts = {
    stdio: 'inherit',
    env: newEnv,
    cwd: binDir
  }
  const child = spawn(cmd, args, opts)
  child.on('exit', code => {
    console.log('exit code: ', code)
    const data = fs.lstatSync(fileName)
    console.log('data: ', JSON.stringify(data, null, '  '))
    // return callback()
    console.log('push file to s3 begin: ', fileName)
    console.log('S3_UPLOAD_BUCKET: ', S3_UPLOAD_BUCKET)
    const key = 'video.mp4'
    console.log('s3 key: ', key)
    const s3Params = {
      Key: key,
      Body: fs.createReadStream(fileName),
      Bucket: S3_UPLOAD_BUCKET
    }
    const s3 = new AWS.S3()
    return s3.putObject(s3Params).promise()
      .then(() => {
        console.log('upload to s3 complete')
        callback()
      })
      .catch((err) => {
        console.error('upload to s3 failed: ', err)
        callback(err)
      })
  })
}

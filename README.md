# Mr. Uploader
jQuery plugin for simplified photo cropping and uploading.

## Installation

- jQuery is a requirement and must be loaded before the js file of this package.
- Clone this repo
- Copy the files from the `dist/` directory into the directory where you'll be serving your static assets

## Usage

- Use `upload = $('selector').mrUploader({uploadUrl: '/upload'});` to start using this package.

- Here's full snippet:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Mr. Uploader</title>
    <link rel="stylesheet" type="text/css" href="dist/css/mr-uploader.min.css">
</head>
<body>

    <button id="uploader">Upload Photos</button>

    <script type="text/javascript" src="//code.jquery.com/jquery-2.1.1.min.js"></script>
    <script type="text/javascript" src="dist/js/mr-uploader.all.min.js"></script>

    <script type="text/javascript">
        upload = $("#uploader").mrUploader({uploadUrl: '/upload'});
    </script>
</body>
</html>
```

- The `upload` variable will now be a `MrUploader` instance
- Access the photos uploaded using the `uploads` key on the instance
- A sample of an `upload` is the following:

```javascript
{
    "response": {}, // The upload response from the server
    "$image", // A jQuery image object representing the uploaded image
    "meta": {
        "width": 1920, // Original image width
        "height": 1080, // Original image height
        "size": 140210, // Original image size in bytes
        "type": 'image/png', // Image MIME type
        "name": 'my-image.png' // Original image file name on client's disk
    },
    "crop": {
        "width": 123, // Crop width
        "height": 456, // Crop height
        "x": 834, // Crop X
        "x2": 747, // Crop X2
        "y": 773, // Crop Y
        "y2": 836 // Crop Y2
    }
}
```

For more examples please check the `example` folder of this package.

## Event Handlers
You may attach handlers to events to be notified when they occur.

### Events

#### upload
This event will be called when an upload is **successfully** completed

```javascript
upload = $('element').mrUploader();
upload.on('upload', function (event, data) {
    // e is the jQuery event
    // data is the upload data
});
```

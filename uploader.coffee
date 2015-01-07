(($, window) ->

    class MrUploader

        defaults:
            multiple: true
            cropping: false
            uploadUrl: '/upload.php'
            crop:
                boxWidth: 800
                aspectRatio: 3/2
                keySupport: false
                allowSelect: false
                minSize: [300, 200]
                setSelect: [0, 0, 600, 400]

        constructor: (el, options)->
            @$el = $(el)
            @$options = $.extend({}, @defaults, options)
            @addContent()
            @$el.click @onElementClick
            @setStaged(null)

        onElementClick: =>
            @showFullscreen()

        addContent: ->
            @$container = $('<div/>')
                .hide()
                .addClass('mr-uploader-fullscreen-mode')
                .css('text-align', 'center')

            header = $('<div/>')

            close = $('<h1><a href="#" class="mr-uploader-fullscreen-close">&times</a></h1>')
            close.click(@onCloseClick)

            title = $('<h2/>').text('Choose & Crop')
            header.append(close)
            header.append(title)

            # Add header
            @$container.append(header)

            # Cropping Area
            crop = $('<div />')

            @$input = $('<input type="file" accept="image/*" />').css('padding-bottom', '10px')
            @$input.change @onUploaderFileChanged
            # Add input field
            crop.append(@$input)

            @$photos = $('<div id="mr-uploader-images">&nbsp;</div>')
            # Add photos container
            crop.append(@$photos)

            upload = $('<button>Upload</button>')
            upload.click @onUploadClick
            crop.append(upload)

            # Add the upload button
            @$container.append(crop)

            @$container.append('<hr />')

            @$previews = $('<div />')
            @$container.append(@$previews)

            # Append content to the DOM
            $('body').append(@$container)

        onCroppingSelected: (crop, image, meta)=>
            crop = {
                x: Math.round(crop.x)
                y: Math.round(crop.y)
                x2: Math.round(crop.x2)
                y2: Math.round(crop.y2)
                width: Math.round(crop.w)
                height: Math.round(crop.h)
            }

            meta.width = image.width()
            meta.height = image.height()

            @setStaged({$image: image, meta: meta, crop: crop})

        setStaged: (@staged)=>

        onUploadClick: =>
            return alert('Please choose a photo to upload') if not @staged?

            url = @$options.uploadUrl
            photo = @staged.image.attr('src')
            meta = @staged.meta

            request = $.ajax({
                type: 'POST',
                url: url,
                data: {photo: photo, meta: meta}
                cache: false
            })

            request.done (response, status, xhr)-> console.log response
            request.fail (xhr, status, error)-> console.error error

        onUploaderFileChanged: (e)=>
            input = @$input[0]
            if input.files? and input.files.length > 0
                reader = new FileReader()
                reader.onload = @onReaderLoad
                reader.readAsDataURL(file) for file in input.files

        onReaderLoad: (e)=>
            img = $('<img src="'+e.target.result+'" />')
            crop = @$options.crop
            meta = @getStagedFileMeta()

            preview = $('<div class="mr-uploader-preview"/>')

            previewImage = $('<img />').attr('src', e.target.result)
            preview.html(previewImage)

            @$previews.prepend(preview)

            crop.onSelect = (crop)=> @onCroppingSelected(crop, img, meta)
            crop.onChange = (crop)=> @changePreview(crop, previewImage)

            @$photos.html(img)
            img.Jcrop(crop)

            @updateElementText()

        changePreview: (crop, $thumbnail)=>
            if @staged?
                rx = 300 / crop.w
                ry = 200 / crop.h

                $thumbnail.css({
                    marginTop: '-' + Math.round(ry * crop.y) + 'px',
                    marginLeft: '-' + Math.round(rx * crop.x) + 'px',
                    width: Math.round(rx * @staged.meta.width) + 'px',
                    height: Math.round(ry * @staged.meta.height) + 'px'
                })

        getStagedFileMeta: =>
            input = @$input[0]
            file = input.files[0]
            return {
                name: file.name
                size: file.size
                type: file.type
            }

        updateElementText: => @$el.text()

        onCloseClick: => @hideFullscreen()

        showFullscreen: => @$container.fadeIn()

        hideFullscreen: => @$container.fadeOut()

    # Define the plugin
    $.fn.extend mrUploader: (option, args...) ->
        $this = @first()
        data = $this.data('mrUploader')

        if !data
            upload = new MrUploader(this, option)
            $this.data 'mrUploader', (data = upload)
            return upload
        if typeof option == 'string'
            data[optiokn].apply(data, args)


)(window.jQuery, window)

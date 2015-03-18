(($, window) ->

    class MrUploader

        defaults:
            multiple: true
            cropping: true
            onClick: true
            uploadUrl: '/upload.php'
            aspectRatio: 'landscape'
            crop:
                boxWidth: 800
                aspectRatio: 3/2
                keySupport: false
                allowSelect: false
                minSize: [300, 200]
                setSelect: [0, 0, 600, 400]

        constructor: (el, options)->
            @$el = $(el)
            @$options = $.extend(true, {}, @defaults, options)
            # The elements that we need to keep hold of, so that we show/hide them based on whether there's
            # a photo staged (chosen for upload) or not, respectively.
            @photoActionsElements = []
            # add the content to the container
            @addContent()

            @$el.click(@onElementClick) if @$options.onClick is true
            @setStaged(null)
            # All the uploaded stuff will live here
            @uploads = []

        on: (event, callback)=> $(@).on(event, callback)

        onElementClick: (e)=>
            e.preventDefault()
            @showFullscreen()

        getHeaderContent: =>
            header = $('<div/>')

            close = $('<h1><a href="#" class="mr-uploader-fullscreen-close">&times</a></h1>')
            close.click(@onCloseClick)

            title = $('<h2/>').text('Choose & Crop')

            ratioOptions = @getRatioOptions()

            @photoActionsElements.push(ratioOptions)

            header.append(close, title, ratioOptions)

            return header

        getRatioOptions: =>
            squareLabel = $(' <label for="mr-uploader-square-ratio">Square</label> ')
            @squareInput    =  $(' <input type="radio" id="mr-uploader-square-ratio" name="mr-uploader-ratio" value="square"> ')
            @squareInput.click => @setSquareAspectRatio()
            @squareInput.attr('checked', true) if @$options.aspectRatio is 'square'
            square = $('<div />').append(squareLabel, @squareInput)

            portraitLabel = $(' <label for="mr-uploader-portrait-ratio">Portrait</label> ')
            @portraitInput  = $(' <input type="radio" id="mr-uploader-portrait-ratio" name="mr-uploader-ratio" value="portrait"> ')
            @portraitInput.attr('checked', true) if @$options.aspectRatio is 'portrait'
            @portraitInput.click => @setPortraitAspectRatio()
            portrait = $('<div />').append(portraitLabel, @portraitInput)

            landscapeLabel = $(' <label for="mr-uploader-landscape-ratio">Landscape</label> ')
            @landscapeInput = $(' <input type="radio" id="mr-uploader-landscape-ratio" name="mr-uploader-ratio" value="landscape"> ')
            @landscapeInput.attr('checked', true) if @$options.aspectRatio is 'landscape'
            @landscapeInput.click => @setLandscapeAspectRatio()
            landscape = $('<div />').append(landscapeLabel, @landscapeInput)

            return $('<div class="mr-uploader-ratio-options"></div>')
                .append(square)
                .append(portrait)
                .append(landscape)

        getCroppingAreaContent: =>
            crop = $('<div />')

            # Add input field
            @$input = $('<input id="mr-uploader-file-input" type="file" accept="image/*" />')
            @$input.change @onUploaderFileChanged
            crop.append(@$input)

            # Add photos container
            @$photos = $('<div id="mr-uploader-images">&nbsp;</div>')
            crop.append(@$photos)

            # Add upload button
            upload = $('<button class="btn">Upload</button>')
            upload.click(@onUploadClick)

            cancel = $('<button class="btn">Cancel</button>')
            cancel.click(@onCancelClick)

            @photoActionsElements.push(upload, cancel)

            crop.append(upload)
            crop.append(cancel)

            return crop

        addContent: ->
            @$container = $('<div/>')
                .hide()
                .addClass('mr-uploader-fullscreen-mode')
                .css('text-align', 'center')

            # Add header
            @$container.append(@getHeaderContent())
            # draw the cropping area
            @$croppingArea = @getCroppingAreaContent()
            # Add the cropping area
            @$container.append(@$croppingArea)
            # separator
            @$container.append('<hr />')

            @$previews = $('<div />')
            # previews will be added dynamically when
            # the image has finished reading (onReaderLoad)
            @$container.append(@$previews)

            @hidePhotoActionElements()

            # Append content to the DOM
            $('body').append(@$container)

        hidePhotoActionElements: => element.hide() for element in @photoActionsElements
        showPhotoActionElements: => element.show() for element in @photoActionsElements

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

        resetCroppingArea: =>
            # reset the cropping area
            @$croppingArea.html(@getCroppingAreaContent())
            @hidePhotoActionElements()

        onCancelClick: (e)=>
            @resetCroppingArea()
            @setStaged(null)
            @$preview.remove()

        onUploadClick: (e)=>
            e.preventDefault()
            return alert('Please choose a photo to upload') if not @staged?

            url = @$options.uploadUrl
            photo = @staged.$image.attr('src')
            meta = @staged.meta
            crop = @staged.crop

            $overlay = @getPreviewOverlay()

            request = $.ajax({
                type: 'POST',
                url: url,
                cache: false
                dataType: 'json'
                data: {photo: photo, meta: meta, crop: crop}
                beforeSend: (xhr, settings)=>
                    # remove any previous overlays (if any)
                    @$preview.find('.mr-uploader-preview-overlay').each -> this.remove()
                    # add the overlay to the preview
                    @$preview.prepend($overlay)
                    # disable cropping
                    @Jcrop.disable()
            })

            request.done (response, status, xhr)=>
                @staged.response = response
                # remove staged photo
                @uploads.push(@staged)
                # reset the cropping area, preparing for another one
                @resetCroppingArea()
                # display success on uploaded image's overlay
                $overlay.html('&#10003')
                # tell listeners about the upload
                $(@).trigger('upload', @staged);
                # clear the stage
                @setStaged(null)
            request.fail (xhr, status, error)=>
                $overlay.addClass('error').html('&times; Upload failed, please retry')

        getPreviewOverlay: ->
            $('<div class="mr-uploader-preview-overlay" />')
                .append('<div class="mr-uploader-spinner"><div class="mr-uploader-spinner-bounce1"></div><div class="mr-uploader-spinner-bounce2"></div><div class="mr-uploader-spinner-bounce3"></div></div>')

        onUploaderFileChanged: (e)=>
            input = @$input[0]
            if input.files? and input.files.length > 0
                reader = new FileReader()
                reader.onload = @onReaderLoad
                reader.readAsDataURL(file) for file in input.files
                @$input.hide()
                @showPhotoActionElements()

        onReaderLoad: (e)=>
            img = $('<img src="'+e.target.result+'" />')
            crop = @$options.crop
            meta = @getStagedFileMeta()

            @$preview = $('<div class="mr-uploader-preview mr-uploader-ar-'+@$options.aspectRatio+'"/>')

            previewImage = $('<img />').attr('src', e.target.result)
            @$preview.html(previewImage)

            @$previews.prepend(@$preview)

            crop.onSelect = (crop)=> @onCroppingSelected(crop, img, meta)
            crop.onChange = (crop)=> @changePreview(crop, previewImage)

            @$photos.html(img)

            self = @
            img.Jcrop crop, -> self.Jcrop = this

        getPreviewWidth: =>
            switch @$options.aspectRatio
                when 'square', 'portrait' then 200
                when 'landscape' then 300

        getPreviewHeight: =>
            switch @$options.aspectRatio
                when 'square', 'landscape' then 200
                when 'portrait' then 300

        changePreview: (crop, $thumbnail)=>
            if @staged?
                width = @getPreviewWidth()
                height = @getPreviewHeight()
                rx = width / crop.w
                ry = height / crop.h

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

        onCloseClick: => @hideFullscreen()

        showFullscreen: => @$container.fadeIn()

        show: => @showFullscreen()

        setSquareAspectRatio: =>
            if @$options.aspectRatio isnt 'square'
                @$preview?.removeClass('mr-uploader-ar-'+@$options.aspectRatio)
                @$options.aspectRatio = 'square'
                @$options.crop.aspectRatio = 2/2
                @$options.crop.minSize = [200, 200]
                @Jcrop?.setOptions(@$options.crop)
                @$preview?.addClass('mr-uploader-ar-'+@$options.aspectRatio)
                @squareInput?.attr('checked', true)

        setPortraitAspectRatio: =>
            if @$options.aspectRatio isnt 'portrait'
                @$preview?.removeClass('mr-uploader-ar-'+@$options.aspectRatio)
                @$options.aspectRatio = 'portrait'
                @$options.crop.aspectRatio = 2/3
                @$options.crop.minSize = [200, 300]
                @Jcrop?.setOptions(@$options.crop)
                @$preview?.addClass('mr-uploader-ar-'+@$options.aspectRatio)
                @portraitInput?.attr('checked', true)

        setLandscapeAspectRatio: =>
            if @$options.aspectRatio isnt 'landscape'
                @$preview?.removeClass('mr-uploader-ar-'+@$options.aspectRatio)
                @$options.aspectRatio = 'landscape'
                @$options.crop.aspectRatio = 3/2
                @$options.crop.minSize = [300, 200]
                @Jcrop?.setOptions(@$options.crop)
                @$preview?.addClass('mr-uploader-ar-'+@$options.aspectRatio)
                @landscapeInput?.attr('checked', true)

        setAspectRatio: (aspectRatio)=>
            switch aspectRatio
                when 'square' then @setSquareAspectRatio()
                when 'portrait' then @setPortraitAspectRatio()
                when 'landscape' then @setLandscapeAspectRatio()

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

window.onload = ->
	class Tagrid
		
		body: document.getElementsByTagName('body')[0]
		maincontent: document.getElementById 'main-content'
		input: document.getElementById 'input'
		inputWrapper: document.getElementById 'input-wrapper'
		form: document.getElementById 'form'
		footer: document.getElementById 'footer'
		imagesWrapper: document.getElementById 'images-wrapper'
		tagNameDisplay: document.getElementById 'tagname-display'
		pagination: document.getElementById 'pagination'
		showMoreLink: document.getElementById 'show-more'

		modal: undefined
		tagName: undefined

		apis: 
			instagram: undefined
			flickr: undefined
			px: undefined

		clientId: 'a0f68c5728b94e54a15103a6edd6c5f7'

		init: ->
			do @bindEvents
			@apis.instagram = new InstagramApi()
			@apis.flickr = new FlickrApi()
			@apis.px = new PxApi()
			@tagName = window.location.hash.substr 1
			if @tagName
				history.pushState 
					name: 'album'
					tagName: @tagName
				, 'album'
				do @setStateAlbum
				@getMedia @tagName
			else
				history.pushState
					name: 'blank'
				, 'blank'
				do @setStateBlank

		bindEvents:	->
			$body = $ @body
			$body.on 'click', '.show-more', @onShowMoreClicked
			$body.on 'click', '.image', @onImageClicked
			$(@form).on 'submit', @onFormSubmit
			window.onpopstate = (event) =>
				if event.state?.name is 'modal'
					
				else if event.state?.name is 'album'
					do @modal.remove
				else


		getMedia: ->
			@imagesWrapper.innerHTML = ''
			do @request

		hasNoMorePages: ->
			do @apis.instagram.hasNoMorePages and
			do @apis.flickr.hasNoMorePages and
			do @apis.px.hasNoMorePages

		onImageClicked: (event) =>
			do event.stopPropagation
			target = event.currentTarget
			@modal = @modal or new Modal
			@modal.init
				images: $ '.image'
				index: $(target).index()
				element: target
				tagName: @tagName

		onShowMoreClicked: (event) =>
			do event.preventDefault
			do @request
			$(@showMoreLink).addClass 'hidden'

		onFormSubmit: (event) =>
			do event.preventDefault
			window.location.hash = @input.value
			@tagName = @input.value
			@tagNameDisplay.innerHTML = @tagName
			@input.value = ''
			do @setStateAlbum
			do @getMedia

		request: ->
			obj = 
				tagName: @tagName
				wrapper: @imagesWrapper
			instaReq = @apis.instagram.request @clone obj
			flickrReq = @apis.flickr.request @clone obj
			pxReq = @apis.px.request @clone obj
			$.when(instaReq, flickrReq, pxReq).always (instaReq, flickrReq, pxReq) =>
				if do @hasNoMorePages
					$(@showMoreLink).addClass 'hidden'
					do @resetApis
				else
					$(@showMoreLink).removeClass 'hidden'

		setStateAlbum: ->
			@tagNameDisplay.innerHTML = @tagName
			do $(@inputWrapper).hide
			$(@body).addClass 'state-album'
			$(@body).removeClass 'state-blank'
			
		setStateBlank: ->
			@tagNameDisplay.innerHTML = 'Tagrid'
			do $(@inputWrapper).show
			$(@body).removeClass 'state-album'
			$(@body).addClass 'state-blank'


		resetApis: ->
			do @apis.instagram.reset
			do @apis.flickr.reset
			do @apis.px.reset

		clone: (obj) ->
			$.extend true, {}, obj

	tagrid = new Tagrid()
	do tagrid.init
class Api

	clientId: undefined
	urlBase: undefined
	jsonp: true
	callbackName: 'callback'

	getUrl: (options) ->
		console.error 'implement this method'

	handleResponse: (response, wrapper) ->
		console.error 'implement this method'

	createImage: (obj, wrapper) ->
		console.error 'implement this method'

	getMedia: (tagName) ->
			@request
				tagName: tagName
				nextTagId: @nextTagId
				success: (response) =>
					@handleResponse response, wrapper
		

	request: (options, callbackFunction) ->
		return if @hasNoMorePages()
		# console.log options
		options = options or {}
		options.data = options.data or {}
		currentUrl = @getUrl options
		dataType = 'json'
		if @jsonp
			dataType = 'jsonp'
		$.ajax
			type: "GET"
			dataType: dataType
			jsonp: @callbackName
			cache: false
			url: currentUrl
			success: (data) =>
				@handleResponse data, options.wrapper


	serializeParams: (obj) ->
		str = []
		for p of obj
			str.push encodeURIComponent(p) + "=" + encodeURIComponent obj[p]
		str.join "&"

	clone: (obj) ->
		return obj  if null is obj or "object" isnt typeof obj
		copy = obj.constructor()
		for attr of obj
			copy[attr] = obj[attr]  if obj.hasOwnProperty(attr)
		copy

class FlickrApi extends Api

	urlBase: 'http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=b27da0bf9ed420c9402253b983a73466&per_page=20&format=json&tags='
	callbackName: 'jsoncallback'

	page: undefined
	pages: undefined

	getUrl: (options) ->
		# options.data.max_tag_id = @nextTagId
		if @page and @hasMorePages()
			options.data.page = @page
		queryString = @serializeParams options.data
		options.url = @urlBase + options.tagName + '&' + queryString

	handleResponse: (response, wrapper) ->
		# console.log 'flickr response done', response
		if response.stat is 'ok'
			@updatePageNumber response.photos.page, response.photos.pages
			for img in response.photos.photo

				urlObjLow = 
					farm: img.farm
					secret: img.secret
					server: img.server
					id: img.id
					size: 'q'

				urlObjHi = @clone urlObjLow
				urlObjHi.size = 'c'

				obj = 
					urls: 
						low: @getImageUrl urlObjLow
						hi: @getImageUrl urlObjHi
						original: 'http://www.flickr.com/photos/'+img.owner+'/'+img.id+'/'
					caption: img.title or ''
					id: img.id

				@createImage obj, wrapper

	getImageUrl: (obj) ->
		'http://farm'+obj.farm+'.staticflickr.com/'+obj.server+'/'+obj.id+'_'+obj.secret+'_'+obj.size+'.jpg'

	createImage: (obj, wrapper) ->
		newImage = $ templates.image
			id: obj.id
			urls: obj.urls
			caption: obj.caption
			service: "flickr"

		wrapper.appendChild newImage[0]

	updatePageNumber: (page, pages) ->
		@page = page+1
		@pages = pages

	hasNoMorePages: ->
		(@page isnt undefined) and (@page >= @pages)

	hasMorePages: ->
		not @hasNoMorePages()

	reset: ->
		@page = undefined
		@pages = undefined


class InstagramApi extends Api

	clientId: 'a0f68c5728b94e54a15103a6edd6c5f7'
	urlBase: 'https://api.instagram.com/v1/'

	nextTagId: undefined

	getUrl: (options) ->
		options.data.client_id = @clientId
		options.data.max_tag_id = @nextTagId
		queryString = @serializeParams options.data
		options.url = @urlBase + 'tags/' + options.tagName + '/media/recent' + "?" + queryString
		options.url

	handleResponse: (response, wrapper) ->
		# console.log 'instagram response done', response
		if response.meta.code is 400
			console.log "no content"
		else
			for img in response.data
				obj = 
					urls: 
						low: img.images.low_resolution.url
						hi: img.images.standard_resolution.url
						original: img.link
					caption: img.caption?.text
					id: img.id
				@createImage obj, wrapper

		@nextTagId = response.pagination?.next_max_tag_id or null

	createImage: (obj, wrapper) ->
		newImage = $ templates.image
			id: obj.id
			urls: obj.urls
			caption: obj.caption
			service: "instagram"
		wrapper.appendChild newImage[0]

	hasNoMorePages: ->
		return @nextTagId is null

	reset: ->
		@nextTagId = undefined

class PxApi extends Api

	clientId: 'b532861666658472fe60f2f16a446b53'
	urlBase: 'https://api.500px.com/v1/photos/search?consumer_key=kajlb5sMDvyBqrI3OYeZrRDpVPRFx8yzfsBY9RLs&tag='

	page: undefined
	pages: undefined

	jsonp: false

	getUrl: (options) ->
		# options.data.max_tag_id = @nextTagId
		# queryString = @serializeParams options.data
		options.data = options.data or {}
		if @page and @hasMorePages()
			options.data.page = @page + 1
		queryString = @serializeParams options.data
		options.url = @urlBase + options.tagName + '&' + queryString

	handleResponse: (response, wrapper) ->
		# console.log 'px response done', response
		if response.current_page
			@updatePageNumber response.current_page, response.total_pages
			for img in response.photos
				lowUrl = img.image_url
				hiUrl = lowUrl.substr(0,lowUrl.length-5)+'4.jpg'
				obj = 
					id: img.id
					urls: 
						low: lowUrl
						hi: hiUrl
						original: 'http://500px.com/photo/' + img.id
					caption: img.name + ' by ' + img.user.fullname
					user: img.user.username

				@createImage obj, wrapper

	createImage: (obj, wrapper) ->
		newImage = $ templates.image
			id: obj.id
			urls: obj.urls
			caption: obj.caption
			service: "px"
		wrapper.appendChild newImage[0]

	updatePageNumber: (page, pages) ->
		@page = page
		@pages = pages

	hasNoMorePages: ->
		!!((@page isnt undefined) and (@page >= @pages))

	hasMorePages: ->
		not @hasNoMorePages()

	reset: ->
		@page = undefined
		@pages = undefined


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
			history.pushState 
				name: 'album'
				tagName: @tagName
			, 'album'

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

class Modal

	el: undefined
	imagesWrapper: undefined
	images: undefined
	swipe: undefined
	currentIndex: undefined
	maxIndex: undefined

	init: (options) ->
		@currentIndex = options.index
		@images = options.images
		@maxIndex = options.images.length - 1

		history.pushState
			name: 'modal'
			tagName: options.tagName
		, 'modal'

		unless @el = document.getElementById 'modal'
			newModal = $ templates.modal()
			$('body').append newModal
			@el = document.getElementById 'modal'
			@imagesWrapper = document.getElementById 'modal-content'
		
		do @insertElements

		do @bindEvents

		@swipe = Swipe document.getElementById('swipe'),
			startSlide: 2
			disableScroll: true
			callback: @onSwiped

	bindEvents: ->
		$(document).keyup (event) =>
			if event.which is 27
				do history.back
			else if event.which is 37
				do @goToPrev
			else if event.which is 39
				do @goToNext
		$el = $ @el
		$el.on 'click', '.js-close', (event) =>
			do history.back
		$el.on 'click', '.modal__arrow--left', (event) =>
			do @goToPrev
		$el.on 'click', '.modal__arrow--right', (event) =>
			do @goToNext

	remove: ->
		do @el.remove

	goToNext: ->
		do @swipe.next

	goToPrev: ->
		do @swipe.prev

	insertElements: ->
		@imagesWrapper.innerHTML = ''
		for i in [0..4]
			# console.log @getRightNumber i
			imageEl = @createImage @getRightNumber i
			frag = document.createElement 'div'
			frag.id = 'bigImageWrapper'+i
			frag.classList.add 'big-image-wrapper'
			frag.dataset.index = @getRightNumber i
			frag.innerHTML = imageEl
			@imagesWrapper.appendChild frag

	getRightNumber: (i) ->
		if i is 0
			@prevIndex @prevIndex @currentIndex
		else if i is 1
			@prevIndex @currentIndex
		else if i is 2
			@currentIndex
		else if i is 3
			@nextIndex @currentIndex
		else if i is 4
			@nextIndex @nextIndex @currentIndex

	currentIndexUp: ->
		@currentIndex = @nextIndex()

	currentIndexDown: ->
		@currentIndex = @prevIndex()

	nextIndex: (index) ->
		if index is @maxIndex
			0
		else
			index+1

	prevIndex: (index) ->
		if index is 0
			@maxIndex
		else
			index-1

	createImage: (index) ->
		element = @images[index]
		data = element.dataset
		bigImage = templates.bigimage
			id: element.id
			url: data.fullurl
			original: data.original
			alt: data.caption
			caption: data.caption
			service: data.service
			index: index
		return bigImage

	onSwiped: (index, elem) =>
		$elem = $ elem
		
		# Set previous index and current
		@currentIndex = parseInt $elem.find('.big-image').data 'index'
		# console.log '@currentIndex', @currentIndex

		# Are we going up or down
		currentPosition = $elem.index()
		# console.log 'currentPosition', currentPosition

		switchPositions = @getSwitchPositions currentPosition

		switchIndices = []
		switchIndices[0] = @prevIndex @prevIndex @currentIndex
		switchIndices[1] = @nextIndex @nextIndex @currentIndex
		
		switchElems = [] 
		switchElems[0] = $ '#bigImageWrapper'+switchPositions[0]
		switchElems[1] = $ '#bigImageWrapper'+switchPositions[1]

		indices = ''
		indices += el.dataset.index + '  ' for el in $(@imagesWrapper).find '.big-image'

		# console.log indices
		# console.log 'currentPosition', currentPosition
		# console.log "replacing "+switchPositions[0]+" with " +  switchIndices[0]
		# console.log "replacing "+switchPositions[1]+" with " +  switchIndices[1]

		switchElems[0].html @createImage switchIndices[0]
		switchElems[1].html @createImage switchIndices[1]

	getSwitchPositions: (position) ->
		if position is 4
			[2,1]
		else if position is 3
			[1,0]
		else if position is 2
			[0,4]
		else if position is 1
			[4,3]
		else if position is 0
			[3,2]



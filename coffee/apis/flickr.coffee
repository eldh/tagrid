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
		console.log 'flickr response done', response
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


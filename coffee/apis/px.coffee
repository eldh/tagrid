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
		console.log 'px response done', response
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


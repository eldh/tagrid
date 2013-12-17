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
		console.log 'instagram response done', response
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

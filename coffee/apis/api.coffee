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
		console.log options
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

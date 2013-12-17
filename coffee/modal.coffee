
class Modal

	el: undefined
	imagesWrapper: undefined
	images: undefined
	swipe: undefined
	currentIndex: undefined

	init: (options) ->
		@currentIndex = options.index
		unless @el = document.getElementById 'modal'
			newModal = $ templates.modal()
			$('body').append newModal
			@el = document.getElementById 'modal'
			@imagesWrapper = document.getElementById 'modal-content'
		
		@imagesWrapper.innerHTML = ''
		htmlString = ''
		for img in options.images
			htmlString += @createImage img 
		@imagesWrapper.innerHTML = htmlString
		@swipe = Swipe document.getElementById('swipe'),
			startSlide: @currentIndex
			disableScroll: true
			callback: @onSwiped
		@swipe.slide @currentIndex
		@images = $(@imagesWrapper).find '.big-image'

		@loadImage @currentIndex
		@loadImage @currentIndex - 1
		@loadImage @currentIndex + 1

		do @bindEvents

	bindEvents: ->
		$(document).keyup (event) =>
			if event.which is 27
				do @remove
			else if event.which is 37
				do @goToPrev
			else if event.which is 39
				do @goToNext
		$el = $ @el
		$el.on 'click', '.js-close', (event) =>
			do @remove
		$el.on 'click', '.modal__arrow--left', (event) =>
			do @goToPrev
		$el.on 'click', '.modal__arrow--right', (event) =>
			do @goToNext

	remove: ->
		do @el.remove

	goToNext: ->
		do @swipe.next
		@currentIndex++
		@loadImage (@currentIndex + 1)

	goToPrev: ->
		do @swipe.prev
		@currentIndex--
		@loadImage (@currentIndex - 1)

	loadImage: (index) ->
		image = @images.eq(index).find '.js-bigimg'
		return if image.attr('src') is image.attr('data-src')
		url = image.attr 'data-src'
		image.attr 'src', url

	createImage: (element) ->
		data = element.dataset
		bigImage = templates.bigimage
			id: element.id
			url: data.fullurl
			original: data.original
			alt: data.caption
			caption: data.caption
			service: data.service
		return bigImage

	onSwiped: (index, elem) =>
		@loadImage index+1
		@loadImage index-1

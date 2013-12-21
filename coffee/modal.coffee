
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

	goToPrev: ->
		do @swipe.prev

	insertElements: ->
		@imagesWrapper.innerHTML = ''
		for i in [0..4]
			console.log @getRightNumber i
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
		console.log '@currentIndex', @currentIndex

		# Are we going up or down
		currentPosition = $elem.index()
		console.log 'currentPosition', currentPosition

		switchPositions = @getSwitchPositions currentPosition

		switchIndices = []
		switchIndices[0] = @prevIndex @prevIndex @currentIndex
		switchIndices[1] = @nextIndex @nextIndex @currentIndex
		
		switchElems = [] 
		switchElems[0] = $ '#bigImageWrapper'+switchPositions[0]
		switchElems[1] = $ '#bigImageWrapper'+switchPositions[1]

		indices = ''
		indices += el.dataset.index + '  ' for el in $(@imagesWrapper).find '.big-image'

		console.log indices
		console.log 'currentPosition', currentPosition
		console.log "replacing "+switchPositions[0]+" with " +  switchIndices[0]
		console.log "replacing "+switchPositions[1]+" with " +  switchIndices[1]

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



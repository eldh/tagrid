(function() {
  var Api, FlickrApi, InstagramApi, Modal, PxApi, _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Api = (function() {
    function Api() {}

    Api.prototype.clientId = void 0;

    Api.prototype.urlBase = void 0;

    Api.prototype.jsonp = true;

    Api.prototype.callbackName = 'callback';

    Api.prototype.getUrl = function(options) {
      return console.error('implement this method');
    };

    Api.prototype.handleResponse = function(response, wrapper) {
      return console.error('implement this method');
    };

    Api.prototype.createImage = function(obj, wrapper) {
      return console.error('implement this method');
    };

    Api.prototype.getMedia = function(tagName) {
      var _this = this;
      return this.request({
        tagName: tagName,
        nextTagId: this.nextTagId,
        success: function(response) {
          return _this.handleResponse(response, wrapper);
        }
      });
    };

    Api.prototype.request = function(options, callbackFunction) {
      var currentUrl, dataType,
        _this = this;
      if (this.hasNoMorePages()) {
        return;
      }
      console.log(options);
      options = options || {};
      options.data = options.data || {};
      currentUrl = this.getUrl(options);
      dataType = 'json';
      if (this.jsonp) {
        dataType = 'jsonp';
      }
      return $.ajax({
        type: "GET",
        dataType: dataType,
        jsonp: this.callbackName,
        cache: false,
        url: currentUrl,
        success: function(data) {
          return _this.handleResponse(data, options.wrapper);
        }
      });
    };

    Api.prototype.serializeParams = function(obj) {
      var p, str;
      str = [];
      for (p in obj) {
        str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
      }
      return str.join("&");
    };

    Api.prototype.clone = function(obj) {
      var attr, copy;
      if (null === obj || "object" !== typeof obj) {
        return obj;
      }
      copy = obj.constructor();
      for (attr in obj) {
        if (obj.hasOwnProperty(attr)) {
          copy[attr] = obj[attr];
        }
      }
      return copy;
    };

    return Api;

  })();

  FlickrApi = (function(_super) {
    __extends(FlickrApi, _super);

    function FlickrApi() {
      _ref = FlickrApi.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    FlickrApi.prototype.urlBase = 'http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=b27da0bf9ed420c9402253b983a73466&per_page=20&format=json&tags=';

    FlickrApi.prototype.callbackName = 'jsoncallback';

    FlickrApi.prototype.page = void 0;

    FlickrApi.prototype.pages = void 0;

    FlickrApi.prototype.getUrl = function(options) {
      var queryString;
      if (this.page && this.hasMorePages()) {
        options.data.page = this.page;
      }
      queryString = this.serializeParams(options.data);
      return options.url = this.urlBase + options.tagName + '&' + queryString;
    };

    FlickrApi.prototype.handleResponse = function(response, wrapper) {
      var img, obj, urlObjHi, urlObjLow, _i, _len, _ref1, _results;
      console.log('flickr response done', response);
      if (response.stat === 'ok') {
        this.updatePageNumber(response.photos.page, response.photos.pages);
        _ref1 = response.photos.photo;
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          img = _ref1[_i];
          urlObjLow = {
            farm: img.farm,
            secret: img.secret,
            server: img.server,
            id: img.id,
            size: 'q'
          };
          urlObjHi = this.clone(urlObjLow);
          urlObjHi.size = 'c';
          obj = {
            urls: {
              low: this.getImageUrl(urlObjLow),
              hi: this.getImageUrl(urlObjHi),
              original: 'http://www.flickr.com/photos/' + img.owner + '/' + img.id + '/'
            },
            caption: img.title || '',
            id: img.id
          };
          _results.push(this.createImage(obj, wrapper));
        }
        return _results;
      }
    };

    FlickrApi.prototype.getImageUrl = function(obj) {
      return 'http://farm' + obj.farm + '.staticflickr.com/' + obj.server + '/' + obj.id + '_' + obj.secret + '_' + obj.size + '.jpg';
    };

    FlickrApi.prototype.createImage = function(obj, wrapper) {
      var newImage;
      newImage = $(templates.image({
        id: obj.id,
        urls: obj.urls,
        caption: obj.caption,
        service: "flickr"
      }));
      return wrapper.appendChild(newImage[0]);
    };

    FlickrApi.prototype.updatePageNumber = function(page, pages) {
      this.page = page + 1;
      return this.pages = pages;
    };

    FlickrApi.prototype.hasNoMorePages = function() {
      return (this.page !== void 0) && (this.page >= this.pages);
    };

    FlickrApi.prototype.hasMorePages = function() {
      return !this.hasNoMorePages();
    };

    FlickrApi.prototype.reset = function() {
      this.page = void 0;
      return this.pages = void 0;
    };

    return FlickrApi;

  })(Api);

  InstagramApi = (function(_super) {
    __extends(InstagramApi, _super);

    function InstagramApi() {
      _ref1 = InstagramApi.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    InstagramApi.prototype.clientId = 'a0f68c5728b94e54a15103a6edd6c5f7';

    InstagramApi.prototype.urlBase = 'https://api.instagram.com/v1/';

    InstagramApi.prototype.nextTagId = void 0;

    InstagramApi.prototype.getUrl = function(options) {
      var queryString;
      options.data.client_id = this.clientId;
      options.data.max_tag_id = this.nextTagId;
      queryString = this.serializeParams(options.data);
      options.url = this.urlBase + 'tags/' + options.tagName + '/media/recent' + "?" + queryString;
      return options.url;
    };

    InstagramApi.prototype.handleResponse = function(response, wrapper) {
      var img, obj, _i, _len, _ref2, _ref3, _ref4;
      console.log('instagram response done', response);
      if (response.meta.code === 400) {
        console.log("no content");
      } else {
        _ref2 = response.data;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          img = _ref2[_i];
          obj = {
            urls: {
              low: img.images.low_resolution.url,
              hi: img.images.standard_resolution.url,
              original: img.link
            },
            caption: (_ref3 = img.caption) != null ? _ref3.text : void 0,
            id: img.id
          };
          this.createImage(obj, wrapper);
        }
      }
      return this.nextTagId = ((_ref4 = response.pagination) != null ? _ref4.next_max_tag_id : void 0) || null;
    };

    InstagramApi.prototype.createImage = function(obj, wrapper) {
      var newImage;
      newImage = $(templates.image({
        id: obj.id,
        urls: obj.urls,
        caption: obj.caption,
        service: "instagram"
      }));
      return wrapper.appendChild(newImage[0]);
    };

    InstagramApi.prototype.hasNoMorePages = function() {
      return this.nextTagId === null;
    };

    InstagramApi.prototype.reset = function() {
      return this.nextTagId = void 0;
    };

    return InstagramApi;

  })(Api);

  PxApi = (function(_super) {
    __extends(PxApi, _super);

    function PxApi() {
      _ref2 = PxApi.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    PxApi.prototype.clientId = 'b532861666658472fe60f2f16a446b53';

    PxApi.prototype.urlBase = 'https://api.500px.com/v1/photos/search?consumer_key=kajlb5sMDvyBqrI3OYeZrRDpVPRFx8yzfsBY9RLs&tag=';

    PxApi.prototype.page = void 0;

    PxApi.prototype.pages = void 0;

    PxApi.prototype.jsonp = false;

    PxApi.prototype.getUrl = function(options) {
      var queryString;
      options.data = options.data || {};
      if (this.page && this.hasMorePages()) {
        options.data.page = this.page + 1;
      }
      queryString = this.serializeParams(options.data);
      return options.url = this.urlBase + options.tagName + '&' + queryString;
    };

    PxApi.prototype.handleResponse = function(response, wrapper) {
      var hiUrl, img, lowUrl, obj, _i, _len, _ref3, _results;
      console.log('px response done', response);
      if (response.current_page) {
        this.updatePageNumber(response.current_page, response.total_pages);
        _ref3 = response.photos;
        _results = [];
        for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
          img = _ref3[_i];
          lowUrl = img.image_url;
          hiUrl = lowUrl.substr(0, lowUrl.length - 5) + '4.jpg';
          obj = {
            id: img.id,
            urls: {
              low: lowUrl,
              hi: hiUrl,
              original: 'http://500px.com/photo/' + img.id
            },
            caption: img.name + ' by ' + img.user.fullname,
            user: img.user.username
          };
          _results.push(this.createImage(obj, wrapper));
        }
        return _results;
      }
    };

    PxApi.prototype.createImage = function(obj, wrapper) {
      var newImage;
      newImage = $(templates.image({
        id: obj.id,
        urls: obj.urls,
        caption: obj.caption,
        service: "px"
      }));
      return wrapper.appendChild(newImage[0]);
    };

    PxApi.prototype.updatePageNumber = function(page, pages) {
      this.page = page;
      return this.pages = pages;
    };

    PxApi.prototype.hasNoMorePages = function() {
      return !!((this.page !== void 0) && (this.page >= this.pages));
    };

    PxApi.prototype.hasMorePages = function() {
      return !this.hasNoMorePages();
    };

    PxApi.prototype.reset = function() {
      this.page = void 0;
      return this.pages = void 0;
    };

    return PxApi;

  })(Api);

  window.onload = function() {
    var Tagrid, tagrid;
    Tagrid = (function() {
      function Tagrid() {
        this.onFormSubmit = __bind(this.onFormSubmit, this);
        this.onShowMoreClicked = __bind(this.onShowMoreClicked, this);
        this.onImageClicked = __bind(this.onImageClicked, this);
      }

      Tagrid.prototype.body = document.getElementsByTagName('body')[0];

      Tagrid.prototype.maincontent = document.getElementById('main-content');

      Tagrid.prototype.input = document.getElementById('input');

      Tagrid.prototype.inputWrapper = document.getElementById('input-wrapper');

      Tagrid.prototype.form = document.getElementById('form');

      Tagrid.prototype.footer = document.getElementById('footer');

      Tagrid.prototype.imagesWrapper = document.getElementById('images-wrapper');

      Tagrid.prototype.tagNameDisplay = document.getElementById('tagname-display');

      Tagrid.prototype.pagination = document.getElementById('pagination');

      Tagrid.prototype.showMoreLink = document.getElementById('show-more');

      Tagrid.prototype.modal = void 0;

      Tagrid.prototype.tagName = void 0;

      Tagrid.prototype.apis = {
        instagram: void 0,
        flickr: void 0,
        px: void 0
      };

      Tagrid.prototype.clientId = 'a0f68c5728b94e54a15103a6edd6c5f7';

      Tagrid.prototype.init = function() {
        this.bindEvents();
        this.apis.instagram = new InstagramApi();
        this.apis.flickr = new FlickrApi();
        this.apis.px = new PxApi();
        this.tagName = window.location.hash.substr(1);
        if (this.tagName) {
          this.setStateAlbum();
          return this.getMedia(this.tagName);
        } else {
          return this.setStateBlank();
        }
      };

      Tagrid.prototype.bindEvents = function() {
        var $body;
        $body = $(this.body);
        $body.on('click', '.show-more', this.onShowMoreClicked);
        $body.on('click', '.image', this.onImageClicked);
        return $(this.form).on('submit', this.onFormSubmit);
      };

      Tagrid.prototype.getMedia = function() {
        this.imagesWrapper.innerHTML = '';
        return this.request();
      };

      Tagrid.prototype.hasNoMorePages = function() {
        return this.apis.instagram.hasNoMorePages() && this.apis.flickr.hasNoMorePages() && this.apis.px.hasNoMorePages();
      };

      Tagrid.prototype.onImageClicked = function(event) {
        var target;
        event.stopPropagation();
        target = event.currentTarget;
        this.modal = this.modal || new Modal;
        return this.modal.init({
          images: $('.image'),
          index: $(target).index(),
          element: target
        });
      };

      Tagrid.prototype.onShowMoreClicked = function(event) {
        event.preventDefault();
        this.request();
        return $(this.showMoreLink).addClass('hidden');
      };

      Tagrid.prototype.onFormSubmit = function(event) {
        event.preventDefault();
        window.location.hash = this.input.value;
        this.tagName = this.input.value;
        this.tagNameDisplay.innerHTML = this.tagName;
        this.input.value = '';
        this.setStateAlbum();
        return this.getMedia();
      };

      Tagrid.prototype.request = function() {
        var flickrReq, instaReq, obj, pxReq,
          _this = this;
        obj = {
          tagName: this.tagName,
          wrapper: this.imagesWrapper
        };
        instaReq = this.apis.instagram.request(this.clone(obj));
        flickrReq = this.apis.flickr.request(this.clone(obj));
        pxReq = this.apis.px.request(this.clone(obj));
        return $.when(instaReq, flickrReq, pxReq).always(function(instaReq, flickrReq, pxReq) {
          if (_this.hasNoMorePages()) {
            $(_this.showMoreLink).addClass('hidden');
            return _this.resetApis();
          } else {
            return $(_this.showMoreLink).removeClass('hidden');
          }
        });
      };

      Tagrid.prototype.setStateAlbum = function() {
        this.tagNameDisplay.innerHTML = this.tagName;
        $(this.inputWrapper).hide();
        $(this.body).addClass('state-album');
        return $(this.body).removeClass('state-blank');
      };

      Tagrid.prototype.setStateBlank = function() {
        this.tagNameDisplay.innerHTML = 'Tagrid';
        $(this.inputWrapper).show();
        $(this.body).removeClass('state-album');
        return $(this.body).addClass('state-blank');
      };

      Tagrid.prototype.resetApis = function() {
        this.apis.instagram.reset();
        this.apis.flickr.reset();
        return this.apis.px.reset();
      };

      Tagrid.prototype.clone = function(obj) {
        return $.extend(true, {}, obj);
      };

      return Tagrid;

    })();
    tagrid = new Tagrid();
    return tagrid.init();
  };

  Modal = (function() {
    function Modal() {
      this.onSwiped = __bind(this.onSwiped, this);
    }

    Modal.prototype.el = void 0;

    Modal.prototype.imagesWrapper = void 0;

    Modal.prototype.images = void 0;

    Modal.prototype.swipe = void 0;

    Modal.prototype.currentIndex = void 0;

    Modal.prototype.init = function(options) {
      var htmlString, img, newModal, _i, _len, _ref3;
      this.currentIndex = options.index;
      if (!(this.el = document.getElementById('modal'))) {
        newModal = $(templates.modal());
        $('body').append(newModal);
        this.el = document.getElementById('modal');
        this.imagesWrapper = document.getElementById('modal-content');
      }
      this.imagesWrapper.innerHTML = '';
      htmlString = '';
      _ref3 = options.images;
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        img = _ref3[_i];
        htmlString += this.createImage(img);
      }
      this.imagesWrapper.innerHTML = htmlString;
      this.swipe = Swipe(document.getElementById('swipe'), {
        startSlide: this.currentIndex,
        disableScroll: true,
        callback: this.onSwiped
      });
      this.swipe.slide(this.currentIndex);
      this.images = $(this.imagesWrapper).find('.big-image');
      this.loadImage(this.currentIndex);
      this.loadImage(this.currentIndex - 1);
      this.loadImage(this.currentIndex + 1);
      return this.bindEvents();
    };

    Modal.prototype.bindEvents = function() {
      var $el,
        _this = this;
      $(document).keyup(function(event) {
        if (event.which === 27) {
          return _this.remove();
        } else if (event.which === 37) {
          return _this.goToPrev();
        } else if (event.which === 39) {
          return _this.goToNext();
        }
      });
      $el = $(this.el);
      $el.on('click', '.js-close', function(event) {
        return _this.remove();
      });
      $el.on('click', '.modal__arrow--left', function(event) {
        return _this.goToPrev();
      });
      return $el.on('click', '.modal__arrow--right', function(event) {
        return _this.goToNext();
      });
    };

    Modal.prototype.remove = function() {
      return this.el.remove();
    };

    Modal.prototype.goToNext = function() {
      this.swipe.next();
      this.currentIndex++;
      return this.loadImage(this.currentIndex + 1);
    };

    Modal.prototype.goToPrev = function() {
      this.swipe.prev();
      this.currentIndex--;
      return this.loadImage(this.currentIndex - 1);
    };

    Modal.prototype.loadImage = function(index) {
      var image, url;
      image = this.images.eq(index).find('.js-bigimg');
      if (image.attr('src') === image.attr('data-src')) {
        return;
      }
      url = image.attr('data-src');
      return image.attr('src', url);
    };

    Modal.prototype.createImage = function(element) {
      var bigImage, data;
      data = element.dataset;
      bigImage = templates.bigimage({
        id: element.id,
        url: data.fullurl,
        original: data.original,
        alt: data.caption,
        caption: data.caption,
        service: data.service
      });
      return bigImage;
    };

    Modal.prototype.onSwiped = function(index, elem) {
      this.loadImage(index + 1);
      return this.loadImage(index - 1);
    };

    return Modal;

  })();

}).call(this);

/*
//@ sourceMappingURL=tagrid.js.map
*/
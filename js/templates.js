this["templates"] = this["templates"] || {};

this["templates"]["bigimage"] = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<section class=\"big-image\" id=\"";
  if (stack1 = helpers.id) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.id); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "\" data-index=\"";
  if (stack1 = helpers.index) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.index); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "\" >\n	<img src=\"";
  if (stack1 = helpers.url) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.url); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "\" alt=\"";
  if (stack1 = helpers.caption) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.caption); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "\" class=\"big-image__img js-bigimg\"  onload=\"$(this).addClass('loaded');\" />\n	<div class=\"loading big-image__loading\"></div>\n	<div class=\"big-image__extra\">\n		<a href=\"";
  if (stack1 = helpers.original) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.original); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "\" target=\"_blank\" class=\"big-image__original\">\n			<span class=\"big-image__service big-image__service--";
  if (stack1 = helpers.service) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.service); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "\"></span>\n			<span class=\"big-image__caption\">";
  if (stack1 = helpers.caption) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.caption); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "</span>\n		</a>\n	</div>\n</section>";
  return buffer;
  });

this["templates"]["image"] = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, stack2, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<section class=\"image\" data-fullurl=\""
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0.urls)),stack1 == null || stack1 === false ? stack1 : stack1.hi)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" data-service=\"";
  if (stack2 = helpers.service) { stack2 = stack2.call(depth0, {hash:{},data:data}); }
  else { stack2 = (depth0 && depth0.service); stack2 = typeof stack2 === functionType ? stack2.call(depth0, {hash:{},data:data}) : stack2; }
  buffer += escapeExpression(stack2)
    + "\" data-caption=\"";
  if (stack2 = helpers.caption) { stack2 = stack2.call(depth0, {hash:{},data:data}); }
  else { stack2 = (depth0 && depth0.caption); stack2 = typeof stack2 === functionType ? stack2.call(depth0, {hash:{},data:data}) : stack2; }
  buffer += escapeExpression(stack2)
    + "\" data-original=\""
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0.urls)),stack1 == null || stack1 === false ? stack1 : stack1.original)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" id=\"";
  if (stack2 = helpers.id) { stack2 = stack2.call(depth0, {hash:{},data:data}); }
  else { stack2 = (depth0 && depth0.id); stack2 = typeof stack2 === functionType ? stack2.call(depth0, {hash:{},data:data}) : stack2; }
  buffer += escapeExpression(stack2)
    + "\" >\n	<img src=\""
    + escapeExpression(((stack1 = ((stack1 = (depth0 && depth0.urls)),stack1 == null || stack1 === false ? stack1 : stack1.low)),typeof stack1 === functionType ? stack1.apply(depth0) : stack1))
    + "\" alt=\"";
  if (stack2 = helpers.caption) { stack2 = stack2.call(depth0, {hash:{},data:data}); }
  else { stack2 = (depth0 && depth0.caption); stack2 = typeof stack2 === functionType ? stack2.call(depth0, {hash:{},data:data}) : stack2; }
  buffer += escapeExpression(stack2)
    + "\" class=\"image__img\" onload=\"$(this).addClass('loaded');\" width=\"140\" height=\"140\" />\n</section>";
  return buffer;
  });

this["templates"]["modal"] = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<div id=\"modal\">\n	<div class=\"modal__close js-close\">&times;</div>\n	<div class=\"modal__arrow modal__arrow--left\">‹</div>\n	<div class=\"modal__arrow modal__arrow--right\">›</div>\n\n	<div class=\"swipe\" id=\"swipe\">\n		<div class=\"swipe-wrap\" id=\"modal-content\"></div>\n	</div>\n</div>";
  });
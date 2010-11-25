
$(document).ready(function(){
	$('.tagcanvas').tagcanvas({
		textColour       : '#65944A',
		outlineColour    : '#555555',
		outlineThickness : 1,
		reverse          : true
	});

	$('a#fancybox').fancybox({
		'transitionIn'   : 'elastic',
		'transitionOut'	 : 'elastic',
//		'speedIn'        : 600, 
//		'speedOut'		 : 200, 
		'overlayShow'    : false
	});

	$('a.figure').fancybox({
		'transitionIn'   : 'elastic',
		'transitionOut'	 : 'elastic',
		'titlePosition'  : 'inside',
		'opacity'        : true,
		'showCloseButton': false
	});
});


$(document).ready(function(){
	$("a.lightwindow").colorbox();
	$('a#learn_more_secure, a.learn_more_dorm_ship, a.learn_more_gift').colorbox({width:'700px'});
});//end ready

//function to mark items that are JS removed for real delete
function mark_for_destroy(element, css_class)
{
	$(element).next().next().val(1);
	$(element).parents(css_class).hide();
}


function mark_gift_name_for_destroy(element, css_class)
{
	$(element).parent().next().next().val(1);
	$(element).parents(css_class).hide();
}
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
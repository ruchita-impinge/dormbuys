(function($) {
   $.fn.serializeAnything = function() {

       var toReturn    = [];
       var els         = $(this).find(':input').get();

       $.each(els, function() {

           if (this.name && !this.disabled && (this.checked || /select|textarea/i.test(this.nodeName) || /text|hidden|password/i.test(this.type))) {

               var val = $(this).val();

               toReturn.push( encodeURIComponent(this.name) + "=" + encodeURIComponent( val ) );

           }

       });   
       return toReturn.join("&").replace(/%20/g, "+");
   
  }//end function

})(jQuery);




$(document).ready(function(){
	
	setupFileFields();
	
});//end ready



function setupFileFields()
{	
	$("input[type=file]").each(function(){
	
		if( !$(this).parents(".field").hasClass("file_field_added") ){
			
			$(this).filestyle({ 
				image: "/images/choose_file.jpg",
				imageheight : 31,
				imagewidth : 91,
			    width : 160
			});
			
			$(this).parents(".field").addClass("file_field_added");
			
		}//end if
		
	});//end each
		
}//end setupFileFields


//function to mark items that are JS removed for real delete
function mark_for_destroy(element, css_class)
{
	$(element).next().next().val(1);
	$(element).parents(css_class).hide();
}



/**
 * function to insert the given value in a field
 * at the current cursor location
 */
function insertAtCursor(field, myValue) 
{
	var myField = document.getElementById(field);
	
	//IE support
	if (document.selection) 
	{
		myField.focus();
		sel = document.selection.createRange();
		sel.text = myValue;
	}
	
	//MOZILLA/NETSCAPE support
	else if (myField.selectionStart || myField.selectionStart == '0') 
	{
		var startPos = myField.selectionStart;
		var endPos = myField.selectionEnd;
		myField.value = myField.value.substring(0, startPos)
		+ myValue
		+ myField.value.substring(endPos, myField.value.length);
	} 
	
	else 
	{
		myField.value += myValue;
	}
	
}//end function insertAtCursor



function formatCurrency(num) {
	num = num.toString().replace(/\$|\,/g,'');
	if(isNaN(num))
	num = "0";
	sign = (num == (num = Math.abs(num)));
	num = Math.floor(num*100+0.50000000001);
	cents = num%100;
	num = Math.floor(num/100).toString();
	if(cents<10)
	cents = "0" + cents;
	for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++)
	num = num.substring(0,num.length-(4*i+3))+','+
	num.substring(num.length-(4*i+3));
	return (((sign)?'':'-') + num + '.' + cents);
}


function copyVariationPrices(){


	if($(".variation").length > 0){
		
		var first = $(".variation").eq(0);
		var wh_price	= first.contents().find('.wholesale_price').val();
		var fi_price	= first.contents().find('.freight_in_price').val();
		var ds_fee		= first.contents().find('.drop_ship_fee').val();
		var si_price	= first.contents().find('.shipping_in_price').val();
		var markup		= first.contents().find('.markup').val();
		var list_price 	= first.contents().find('.list_price').val();
		
		for(var i=1; i < $(".variation").length; i++)
		{
			$(".variation").eq(i).contents().find('.wholesale_price').val(wh_price);
			$(".variation").eq(i).contents().find('.freight_in_price').val(fi_price);
			$(".variation").eq(i).contents().find('.drop_ship_fee').val(ds_fee);
			$(".variation").eq(i).contents().find('.shipping_in_price').val(si_price);
			$(".variation").eq(i).contents().find('.markup').val(markup);
			$(".variation").eq(i).contents().find('.list_price').val(list_price);
			
		}//end for loop
		
	}//end if variations > 0
	else
	{
		alert("You must have at least one variation");
	}

}//end function copyVariationPrices
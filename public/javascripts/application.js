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
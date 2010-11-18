class WrapUpAmericaController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  layout "standalone/wrap_up_america"

  def index
    @product = Product.find 6871
  end

end

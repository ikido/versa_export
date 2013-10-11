# -*- encoding : utf-8 -*-
class ExportsController < ApplicationController
  before_filter :ensure_api_session
  respond_to :html, :xml

  def products
    # get 10 products
    @count = VersacommerceAPI::Product.count
    render text: @count
    #@products = VersacommerceAPI::Product.find(:all, :params => {:limit => 10})
  end

end
# -*- encoding : utf-8 -*-
class ExportsController < ApplicationController
  # this around filter makes things extremely slow, since it is
  # validating session on each request
  around_filter :ensure_current_api_session

  # Concerns:
  #
  # 1. Each request to API may fail.
  #    We specify timeout and number of retries.
  #    Need a way to report an error.
  #
  # 2. We may have more products than allowed by limit.
  #    Get total count and keep requesting until we have all products.
  #
  # 3. Request can run too long. Ideally we must use Sidekiq to handle
  #    background queues, but for now Sucker Punch is ok
  #

  def products
    FileUtils.rm(xml_file_path) if File.exists?(xml_file_path)

    # when trying to do that async we get 'Missing site URI' error, need to look into later
    ProductsExport.new.perform(VersacommerceAPI::Base.site, xml_file_path)
    render :products, format: :html
  end

  def xml_file_path
    unless @xml_file_path
      xml_exports_dir = Rails.root.join('public', 'files', 'exports')
      FileUtils.mkdir_p(xml_exports_dir) unless File.exists?(xml_exports_dir)
      @xml_file_path = xml_exports_dir.join "#{params[:action]}.xml"
    end

    @xml_file_path
  end

end
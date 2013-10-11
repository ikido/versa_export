class ProductsExport
  include SuckerPunch::Job

  def perform(controller, site)
    ActiveRecord::Base.connection_pool.with_connection do
      VersacommerceAPI::Base.site = site # dunno why this gets reset

      total_products = VersacommerceAPI::Product.count

      @products = []
      offset = 0
      limit = 40

      begin
        current_products = VersacommerceAPI::Product.find(:all, params: {
          offset: offset,
          limit: limit
        })
        @products = @products + current_products
        offset += limit
      end while @products.size < total_products

      SuckerPunch.logger.info "products.size: #{@products.size}"

      File.open(controller.xml_file_path, 'w') do |f|
        controller.instance_variable_set('@products', @products)
        f.write controller.render_to_string(
          action: 'products',
          formats: [:xml]
        )
      end
    end
  end

end